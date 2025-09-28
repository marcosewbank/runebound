extends CanvasLayer

@export var arena_time_manager: Node
@onready var label = %Label

func _process(_delta: float) -> void:
	if not is_instance_valid(arena_time_manager):
		return

	var time_elapsed: float = arena_time_manager.get_time_elapsed()
	label.text = format_seconds_to_string(time_elapsed)

func format_seconds_to_string(seconds: float) -> String:
	@warning_ignore("integer_division")
	var minutes: int = int(seconds) / 60
	var remaining_seconds: int = int(seconds) % 60
	
	return "%d:%02d" % [minutes, remaining_seconds]
