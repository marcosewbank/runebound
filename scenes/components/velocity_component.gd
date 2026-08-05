extends Node
class_name VelocityComponent

@export var max_speed: int = 40
@export var acceleration: float = 5

var velocity = Vector2.ZERO
var _slow_multiplier: float = 1.0
var _slow_time: float = 0.0


func accelerate_to_player():
	var owner_node2d = owner as Node2D
	if owner_node2d == null:
		return

	var player = get_tree().get_first_node_in_group(Groups.PLAYER) as Node2D
	if player == null:
		return

	var direction = (player.global_position - owner_node2d.global_position).normalized()
	accelerate_in_direction(direction)


func accelerate_to_nearest_target() -> void:
	var owner_node2d = owner as Node2D
	if owner_node2d == null:
		return
	var target := Targeting.get_nearest_attack_target(get_tree(), owner_node2d.global_position)
	if target == null:
		return
	var direction = (target.global_position - owner_node2d.global_position).normalized()
	accelerate_in_direction(direction)


func accelerate_in_direction(direction: Vector2):
	var speed := float(max_speed) * _get_speed_multiplier()
	var desired_velocity = direction * speed
	velocity = velocity.lerp(desired_velocity, 1 - exp(-acceleration * get_physics_process_delta_time()))


func apply_slow(multiplier: float, duration: float) -> void:
	_slow_multiplier = min(_slow_multiplier, clampf(multiplier, 0.15, 1.0))
	_slow_time = max(_slow_time, duration)


func _get_speed_multiplier() -> float:
	if _slow_time > 0.0:
		_slow_time = max(_slow_time - get_physics_process_delta_time(), 0.0)
		if _slow_time <= 0.0:
			_slow_multiplier = 1.0
		return _slow_multiplier
	_slow_multiplier = 1.0
	return 1.0


func move(character_body: CharacterBody2D):
	character_body.velocity = velocity
	character_body.move_and_slide()
	velocity = character_body.velocity
