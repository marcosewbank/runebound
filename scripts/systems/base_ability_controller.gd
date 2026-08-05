extends Node
class_name BaseAbilityController

@export var base_cooldown: float = 1.0
@export var base_damage: float = 5.0

@onready var timer: Timer = $Timer

var _player: Node2D
var _stats_component: StatsComponent


func _ready() -> void:
	_player = get_tree().get_first_node_in_group(Groups.PLAYER) as Node2D
	if _player != null and _player.has_node("StatsComponent"):
		_stats_component = _player.get_node("StatsComponent") as StatsComponent
		_stats_component.stat_changed.connect(on_stat_changed)

	_refresh_cooldown()
	timer.timeout.connect(on_timer_timeout)
	if not timer.autostart:
		timer.start()


func on_timer_timeout() -> void:
	activate()


func activate() -> void:
	push_error("BaseAbilityController.activate() must be overridden")


func get_damage() -> float:
	var multiplier := 1.0
	if _stats_component != null:
		multiplier = _stats_component.get_stat(StatNames.DAMAGE)
	return base_damage * multiplier


func get_cooldown() -> float:
	var attack_rate := 1.0
	if _stats_component != null:
		attack_rate = max(_stats_component.get_stat(StatNames.ATTACK_RATE), 0.01)
	return base_cooldown / attack_rate


func _refresh_cooldown() -> void:
	timer.wait_time = get_cooldown()


func on_stat_changed(stat_name: StringName) -> void:
	if stat_name == StatNames.ATTACK_RATE or stat_name == StatNames.DAMAGE:
		var was_stopped = timer.is_stopped()
		_refresh_cooldown()
		if not was_stopped:
			timer.start()
