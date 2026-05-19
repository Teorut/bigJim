extends Camera3D

@export var target: Node3D

func _physics_process(delta: float) -> void:
	global_position = lerp(global_position, target.global_position, 0.01)
	
	global_rotation.y = lerp_angle(global_rotation.y, target.global_rotation.y, 0.01)
	
	global_rotation.x = lerpf(global_rotation.x, target.global_rotation.x, 0.03)
