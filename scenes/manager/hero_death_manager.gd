extends Node
class_name HeroDeathManager
## Day death → force Night. Night down → camera on Hearth, respawn on wave clear.

signal hero_downed
signal hero_respawned
signal day_death_forced_night

@export var phase_manager: PhaseManager
@export var player: CharacterBody2D
@export var hearth: Node2D
@export var camera: Camera2D
@export var day_death_stub_seconds: float = 0.75

var is_downed: bool = false
var died_during_day: bool = false
var cleared_wave_while_downed: bool = false

var _status_label: Label
var _cutscene_running: bool = false


func _ready() -> void:
	call_deferred("_bootstrap")


func _bootstrap() -> void:
	if player != null and player.get("health_component") != null:
		player.health_component.died.connect(_on_player_died)
	if phase_manager != null:
		phase_manager.wave_cleared.connect(_on_wave_cleared)
		phase_manager.phase_changed.connect(_on_phase_changed)
	_ensure_status_label()


func _ensure_status_label() -> void:
	if _status_label != null:
		return
	var canvas := get_parent().get_node_or_null("HUD") as CanvasLayer
	if canvas == null:
		return
	_status_label = Label.new()
	_status_label.name = "DeathStatusLabel"
	_status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_status_label.offset_left = 160
	_status_label.offset_top = 150
	_status_label.offset_right = 480
	_status_label.offset_bottom = 190
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 14)
	_status_label.visible = false
	canvas.add_child(_status_label)


func _on_player_died() -> void:
	if _cutscene_running or phase_manager == null:
		return
	match phase_manager.phase:
		PhaseManager.Phase.DAY:
			_handle_day_death()
		PhaseManager.Phase.NIGHT:
			_handle_night_down()
		PhaseManager.Phase.DAWN:
			# Treat like night-down edge case: stay down until day, then revive.
			_handle_night_down()


func _handle_night_down() -> void:
	if is_downed:
		return
	is_downed = true
	_set_hero_disabled(true)
	_set_camera_target(hearth)
	_show_status("DOWN — defend the Hearth")
	hero_downed.emit()


func _handle_day_death() -> void:
	_cutscene_running = true
	died_during_day = true
	if phase_manager != null:
		phase_manager.day_deaths += 1
	_set_hero_disabled(true)
	_show_status("Fallen — Night comes unprepared")
	await get_tree().create_timer(day_death_stub_seconds).timeout
	if player != null and hearth != null:
		player.global_position = hearth.global_position + Vector2(0, 24)
	_respawn_hero()
	_show_status("")
	_cutscene_running = false
	day_death_forced_night.emit()
	if phase_manager != null:
		phase_manager.sound_horn()


func _on_wave_cleared() -> void:
	if is_downed:
		cleared_wave_while_downed = true
		if phase_manager != null:
			phase_manager.cleared_while_hero_down = true
		_respawn_hero()
		_show_status("")


func _on_phase_changed(phase: PhaseManager.Phase) -> void:
	# Safety: never stay downed into a fresh Day.
	if phase == PhaseManager.Phase.DAY and is_downed:
		_respawn_hero()
		_show_status("")


func _respawn_hero() -> void:
	if player == null:
		return
	if hearth != null:
		player.global_position = hearth.global_position + Vector2(0, 24)
	if player.health_component != null:
		player.health_component.revive(true)
	_set_hero_disabled(false)
	_set_camera_target(player)
	is_downed = false
	hero_respawned.emit()


func _set_hero_disabled(disabled: bool) -> void:
	if player == null:
		return
	player.set_physics_process(not disabled)
	player.visible = not disabled
	player.collision_layer = 0 if disabled else Layers.PLAYER_BODY
	var hurtbox := player.get_node_or_null("HurtboxComponent") as HurtboxComponent
	if hurtbox != null:
		hurtbox.monitoring = not disabled
		hurtbox.set_deferred("monitorable", not disabled)
	var combat := player.get_node_or_null("PlayerCombat") as PlayerCombat
	if combat != null:
		combat.set_process_unhandled_input(not disabled)
		combat.set_process(not disabled)
	if player.has_method("update_health_display"):
		player.update_health_display()


func _set_camera_target(target: Node2D) -> void:
	if camera == null:
		return
	if camera.has_method("set_follow_target"):
		var mouse_look := target != null and target.is_in_group(Groups.PLAYER)
		camera.call("set_follow_target", target, mouse_look)
	else:
		camera.set("target_node", target)


func _show_status(text: String) -> void:
	if _status_label == null:
		_ensure_status_label()
	if _status_label == null:
		return
	_status_label.text = text
	_status_label.visible = not text.is_empty()
