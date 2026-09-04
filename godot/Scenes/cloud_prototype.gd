extends MeshInstance3D

var speed = 5

# Fetch the arrows direction
@onready var wind_direction = $"../wind_direction"

func _process(delta):
  var direction = -wind_direction.global_transform.basis.z

  direction.y = 0
  direction = direction.normalized()

  # Move the cloud bundle
  global_position += direction * speed * delta
