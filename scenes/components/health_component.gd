extends Node
class_name HealthComponent

signal died
signal health_changed
signal revived

@export var max_health: float = 10
var current_health
var is_dead: bool = false


func _ready():
	current_health = max_health


func damage(damage_amount: float):
	if is_dead:
		return
	current_health = max(current_health - damage_amount, 0)
	health_changed.emit()
	Callable(check_death).call_deferred()


func heal(amount: float) -> void:
	if amount <= 0 or is_dead:
		return
	current_health = min(current_health + amount, max_health)
	health_changed.emit()


func revive(to_full: bool = true) -> void:
	is_dead = false
	if to_full:
		current_health = max_health
	elif current_health <= 0:
		current_health = max_health
	health_changed.emit()
	revived.emit()


func is_damaged() -> bool:
	return current_health < max_health


func get_health_percent():
	if max_health == 0:
		return 0
	return min(current_health / max_health, 1)


func check_death():
	if current_health == 0 and not is_dead:
		is_dead = true
		died.emit()
