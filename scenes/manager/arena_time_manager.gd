extends Node

const DIFFICULTY_INTERVAL = 5

signal arena_difficulty_increased(arena_difficulty: int)
signal run_time_expired

@onready var timer = $Timer

var arena_difficulty = 0


func _ready() -> void:
	timer.timeout.connect(on_timer_timeout)


func _process(_delta):
	var next_time_target = timer.wait_time - ((arena_difficulty + 1) * DIFFICULTY_INTERVAL)

	if timer.time_left <= next_time_target:
		arena_difficulty += 1
		arena_difficulty_increased.emit(arena_difficulty)


func get_time_elapsed():
	return timer.wait_time - timer.time_left


func on_timer_timeout():
	run_time_expired.emit()
