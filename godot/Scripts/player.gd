extends CharacterBody3D

@onready var front_ray: RayCast3D = $FrontRay
@onready var back_ray: RayCast3D = $BackRay
@onready var middle_ray: RayCast3D = $MiddleRay

var rotation_speed = 20
var speed = 10

func _physics_process(delta: float) -> void:
	balancePlayer(delta)
	movePlayer(delta)

func balancePlayer(delta: float):
	if !front_ray.is_colliding() or !back_ray.is_colliding() or !middle_ray.is_colliding():
		return

	global_position.y = middle_ray.get_collision_point().y

	var avg_normal = (front_ray.get_collision_normal() + back_ray.get_collision_normal()).normalized()
	var forward = -global_transform.basis.z
	var right = forward.cross(avg_normal).normalized()
	forward = avg_normal.cross(right).normalized()
	var target_basis = Basis(right, avg_normal, -forward)

	global_transform.basis = global_transform.basis.slerp(target_basis, rotation_speed * delta).orthonormalized()

func movePlayer(delta):
	if Input.is_action_pressed("forward"):
		global_position += transform.basis.x * speed * delta
	if Input.is_action_pressed("backward"):
		global_position -= transform.basis.x * speed * delta
	
	if Input.is_action_pressed("left"):
		rotation.y += 0.04
	if Input.is_action_pressed("right"):
		rotation.y -= 0.04
