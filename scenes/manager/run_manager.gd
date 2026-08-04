extends Node
class_name RunManager

enum State { PLAYING, PAUSED, ENDED }

signal state_changed(new_state: State)

@export var end_screen_scene: PackedScene
@export var arena_time_manager: Node
@export var player: Node

var state: State = State.PLAYING


func _ready() -> void:
	if player != null and player.get("health_component") != null:
		player.health_component.died.connect(on_player_died)
	if arena_time_manager != null:
		arena_time_manager.run_time_expired.connect(on_run_time_expired)


func on_player_died() -> void:
	end_run(false)


func on_run_time_expired() -> void:
	end_run(true)


func end_run(victory: bool) -> void:
	if state == State.ENDED:
		return

	state = State.ENDED
	state_changed.emit(state)
	get_tree().paused = true

	var end_screen_instance = end_screen_scene.instantiate()
	end_screen_instance.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	add_child(end_screen_instance)

	if victory:
		end_screen_instance.set_victory()
	else:
		end_screen_instance.set_defeat()
