extends Camera2D

var desired_offset: Vector2
var min_offset = -200
var max_offset = 200

var target_position = Vector2.ZERO

func _ready():
	make_current()

func _process(delta: float) -> void:
	desired_offset = (get_global_mouse_position() - position) * 0.5
	desired_offset.x = clamp(desired_offset.x, min_offset, max_offset)
	desired_offset.y = clamp(desired_offset.y, min_offset / 2.0, max_offset / 2.0)
	
	# TO-DO: Test this with tilemap. on gray screen it doesn't look good.
	# global_position = acquire_target() + desired_offset
	
	
	acquire_target()
	global_position = global_position.lerp(target_position, 1.0 - exp(-delta * 10))

func acquire_target():
	var player_nodes = get_tree().get_nodes_in_group("player")
	if (player_nodes.size() > 0):
		var player = player_nodes[0] as  Node2D
		global_position = player.global_position
		return player.global_position
