extends CharacterBody2D


const SPEED = 300.0

func _get_direction_input():
	var direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	velocity = direction * SPEED

func _physics_process(_delta: float) -> void:
	_get_direction_input()
	move_and_slide()
