extends CharacterBody2D

@export var MAX_SPEED = 200.0
@export var ACCELERATION_SMOOTHING = 2

func _get_direction_input(delta: float):
	var direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var target_velocity = direction * MAX_SPEED
	velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))

func _physics_process(delta: float) -> void:
	_get_direction_input(delta)
	move_and_slide()
