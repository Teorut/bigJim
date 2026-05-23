extends CharacterBody3D

@onready var front_ray: RayCast3D = $FrontRay
@onready var back_ray: RayCast3D = $BackRay
@onready var middle_ray: RayCast3D = $MiddleRay
@onready var pedals: Node3D = $Mesh/Pedals

var rotation_speed = 20
var speed = 10
var lerped_speed = 0

func _ready() -> void:
	$Mesh/Player/Skeleton3D/LeftLeg.start()
	$Mesh/Player/Skeleton3D/RightLeg.start()
	$Mesh/Player/Skeleton3D/LeftArm.start()
	$Mesh/Player/Skeleton3D/RightArm.start()

func _physics_process(delta: float) -> void:
	balancePlayer(delta)
	movePlayer(delta)
	bikeMomentum(delta)

func bikeMomentum(delta: float):
	var roll = asin(global_basis.x.y)
	var roll_deg = rad_to_deg(roll)
	#print("incline:", roll_deg)
	
	if roll_deg < 0 or roll_deg > 0:
		#global_position += transform.basis.x * (-roll_deg/5) * delta
		
		lerped_speed += -roll_deg/400
		pedals.global_rotation_degrees.z += roll_deg/10

func balancePlayer(delta: float):
	if !front_ray.is_colliding() or !back_ray.is_colliding() or !middle_ray.is_colliding():
		return

	global_position.y = middle_ray.get_collision_point().y

	var avg_normal = (front_ray.get_collision_normal() + back_ray.get_collision_normal()).normalized()
	var forward = -global_transform.basis.z
	
	# Fixar cykelns roll
	var normal_forward = global_transform.basis.x
	var axis = normal_forward.normalized()
	var projected = (avg_normal - normal_forward * avg_normal.dot(normal_forward)).normalized()
	var ref = (Vector3.UP - normal_forward * Vector3.UP.dot(normal_forward)).normalized()
	var roll = atan2(normal_forward.dot(ref.cross(projected)),ref.dot(projected))

	avg_normal = avg_normal.rotated(axis, -roll/1.5)
	
	var right = forward.cross(avg_normal).normalized()
	forward = avg_normal.cross(right).normalized()
	var target_basis = Basis(right, avg_normal, -forward)
	
	global_transform.basis = global_transform.basis.slerp(target_basis, rotation_speed * delta).orthonormalized()

func movePlayer(delta: float):
	var speed_float = 0.1
	
	if Input.is_action_pressed("forward"):
		if lerped_speed < speed:
			lerped_speed += speed_float
		
		pedals.global_rotation_degrees.z -= lerped_speed
	if Input.is_action_pressed("backward"):
		if lerped_speed > -speed:
			lerped_speed -= speed_float
		
		pedals.global_rotation_degrees.z += lerped_speed
	
	global_position += transform.basis.x * lerped_speed * delta
	
	if lerped_speed < -1 or lerped_speed > 1:
		lerped_speed = lerpf(lerped_speed, 0, 0.003)
		if !Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
			$Mesh/Player/AnimationPlayer.play("Idle")
		
		if Input.is_action_pressed("left"):
			rotation.y += 0.02
			$Mesh/Player/AnimationPlayer.play("TurnLeft")
		if Input.is_action_pressed("right"):
			rotation.y -= 0.02
			$Mesh/Player/AnimationPlayer.play("TurnRight")
		
		if $Mesh/Player/Skeleton3D/RightLeg.influence < 1:
			$Mesh/Player/Skeleton3D/RightLeg.influence += 0.1
		if $Mesh/Player/Skeleton3D/RightArm.influence < 1:
				$Mesh/Player/Skeleton3D/RightArm.influence += 0.1
	else:
		var roll = asin(global_basis.x.y)
		var roll_deg = rad_to_deg(roll)
		
		if !Input.is_action_pressed("forward") and !Input.is_action_pressed("backward") and !(roll_deg > 4 or roll_deg < -4):
			$Mesh/Player/AnimationPlayer.play("Stopped")
			
			lerped_speed = 0
			
			$Mesh/Player/Skeleton3D/RightLeg.influence = 0
			$Mesh/Player/Skeleton3D/RightArm.influence = 0
