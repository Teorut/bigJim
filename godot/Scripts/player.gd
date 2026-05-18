extends CharacterBody3D

@onready var front_ray: RayCast3D = $FrontRay
@onready var back_ray: RayCast3D = $BackRay
@onready var middle_ray: RayCast3D = $MiddleRay

var rotation_speed = 20
var speed = 10

func _physics_process(delta: float) -> void:
	balancePlayer(delta)
	movePlayer(delta)
	bikeMomentum(delta)

func bikeMomentum(delta: float):
	var roll = asin(global_basis.x.y)
	var roll_deg = rad_to_deg(roll)
	#print("incline:", roll_deg)
	
	if roll_deg < 0 or roll_deg > 0:
		global_position += transform.basis.x * (-roll_deg/5) * delta

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
	if Input.is_action_pressed("forward"):
		global_position += transform.basis.x * speed * delta
	if Input.is_action_pressed("backward"):
		global_position -= transform.basis.x * speed * delta
	
	if Input.is_action_pressed("left"):
		rotation.y += 0.04
	if Input.is_action_pressed("right"):
		rotation.y -= 0.04
