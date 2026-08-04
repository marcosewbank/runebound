extends Node
class_name NightWaveManager
## Spawns night waves at the run's active door; clears Night when all are dead.

@export var wave_table: WaveTable
@export var phase_manager: PhaseManager
@export var map_root: Node
@export var entities: Node2D
@export var spawn_outward_pixels: float = 28.0

var _alive: int = 0
var _spawning: bool = false
var _run_ended: bool = false


func _ready() -> void:
	if wave_table == null:
		wave_table = load("res://resources/waves/wave_table.tres") as WaveTable
	call_deferred("_bootstrap")


func _bootstrap() -> void:
	if phase_manager == null:
		return
	phase_manager.auto_clear_night = false
	phase_manager.phase_changed.connect(_on_phase_changed)


func _unhandled_input(event: InputEvent) -> void:
	# Debug: clear the wave until Slice 5 combat exists.
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_K:
			_debug_kill_wave()
			get_viewport().set_input_as_handled()


func _on_phase_changed(phase: PhaseManager.Phase) -> void:
	if phase == PhaseManager.Phase.NIGHT:
		_start_wave()


func _start_wave() -> void:
	if _run_ended:
		return
	_spawning = true
	_alive = 0
	var count := wave_table.enemy_count_for_night(phase_manager.nights_survived)
	for i in count:
		if phase_manager.phase != PhaseManager.Phase.NIGHT or _run_ended:
			break
		_spawn_one()
		if i < count - 1:
			await get_tree().create_timer(wave_table.spawn_interval).timeout
	_spawning = false
	_check_clear()


func _spawn_one() -> void:
	if wave_table.enemy_scene == null or entities == null:
		return
	var enemy := wave_table.enemy_scene.instantiate() as Node2D
	entities.add_child(enemy)
	enemy.global_position = _spawn_position()
	_alive += 1
	var health := enemy.get_node_or_null("HealthComponent") as HealthComponent
	if health != null:
		health.died.connect(_on_enemy_died, CONNECT_ONE_SHOT)


func _on_enemy_died() -> void:
	_alive = max(_alive - 1, 0)
	# Defer so queue_free finishes and group counts stay accurate.
	call_deferred("_check_clear")


func _check_clear() -> void:
	if _run_ended:
		return
	if phase_manager == null or phase_manager.phase != PhaseManager.Phase.NIGHT:
		return
	if _spawning:
		return
	if _alive > 0:
		return
	phase_manager.clear_wave()


func _spawn_position() -> Vector2:
	var door: Vector2 = map_root.call(
		"get_door_world_center", phase_manager.active_door
	)
	var center: Vector2 = map_root.call("get_map_center_world")
	var outward := (door - center).normalized()
	if outward == Vector2.ZERO:
		outward = Vector2.DOWN
	return door + outward * spawn_outward_pixels


func _debug_kill_wave() -> void:
	if phase_manager == null or phase_manager.phase != PhaseManager.Phase.NIGHT:
		return
	for enemy in get_tree().get_nodes_in_group(Groups.ENEMY):
		var health := enemy.get_node_or_null("HealthComponent") as HealthComponent
		if health != null:
			health.damage(health.current_health)


func notify_run_ended() -> void:
	_run_ended = true
