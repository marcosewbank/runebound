extends Camera2D

# You can now change these values in the Godot Inspector
@export var follow_speed: float = 8.0
@export var min_offset: float = -15.0
@export var max_offset: float = 15.0

var target_node: Node2D

func _ready():
	make_current()
	# Find the player ONCE at the start, which is more efficient
	target_node = get_tree().get_first_node_in_group("player") as Node2D

func _process(delta: float) -> void:
	# If we don't have a target (e.g., player died), do nothing.
	if not is_instance_valid(target_node):
		return

	# 1. Calculate where the camera SHOULD be (Player Position + Mouse Offset)
	var mouse_offset = (get_global_mouse_position() - target_node.global_position) * 0.25
	mouse_offset.x = clamp(mouse_offset.x, min_offset, max_offset)
	mouse_offset.y = clamp(mouse_offset.y, min_offset / 2.0, max_offset / 2.0)
	
	var target_position = target_node.global_position + mouse_offset

	# 2. Smoothly move the camera's actual position towards the target position
	# The lerp function is simpler and very effective for this!
	global_position = global_position.lerp(target_position, 1.0 - exp(-delta * follow_speed))
