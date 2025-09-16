extends CharacterBody2D

const MAX_SPEED = 200.0

func _get_direction_input():
	var direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	velocity = direction * MAX_SPEED

func _physics_process(_delta: float) -> void:
	_get_direction_input()
	move_and_slide()
