extends MeshInstance3D

# Fetch the arrow
@onready var wind_direction = $"../wind_direction"

var texture_offset = Vector2.ZERO
var speed = 0.2

func _process(delta):
  var direction = wind_direction.global_transform.basis.z
  
  var move_direction = Vector2(direction.x, direction.z).normalized()

  texture_offset += move_direction * speed * delta

  material_override.set_shader_parameter(
	"direction_offset",
	texture_offset
  )

  # #Fetch the arrows rotation
  # var rotation_y = wind_direction.global_rotation.y

  # #Turn the rotation into a value of 0 to 1
  # var offset = fmod(rotation_y, TAU) / TAU

  # #Send the value to the material
  # material_override.set_shader_parameter("direction_offset", offset)
