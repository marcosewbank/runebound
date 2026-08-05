extends Camera2D

@export var follow_speed: float = 20
@export var min_offset: float = -15.0
@export var max_offset: float = 15.0

var target_node: Node2D
var follow_mouse_look: bool = true


func _ready():
	make_current()
	target_node = get_tree().get_first_node_in_group(Groups.PLAYER) as Node2D


func set_follow_target(target: Node2D, mouse_look: bool = true) -> void:
	target_node = target
	follow_mouse_look = mouse_look and target != null and target.is_in_group(Groups.PLAYER)


func _process(delta: float) -> void:
	if not is_instance_valid(target_node):
		return

	var target_position := target_node.global_position
	if follow_mouse_look:
		var mouse_offset = (get_global_mouse_position() - target_node.global_position) * 0.25
		mouse_offset.x = clamp(mouse_offset.x, min_offset, max_offset)
		mouse_offset.y = clamp(mouse_offset.y, min_offset / 2.0, max_offset / 2.0)
		target_position = target_node.global_position + mouse_offset

	global_position = global_position.lerp(target_position, 1.0 - exp(-delta * follow_speed))
