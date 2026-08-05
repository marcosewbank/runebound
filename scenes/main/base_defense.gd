extends Node
## Base-defense loop root. Builds the courtyard map at runtime (tunable exports).

const TILE_SIZE := 16
const GROUND_SOURCE_ID := 0
const GROUND_ATLAS := Vector2i(9, 1)
const WALL_COLOR := Color(0.42, 0.32, 0.22, 1.0)
const ACTIVE_DOOR_COLOR := Color(1.0, 0.2, 0.85, 0.85)

@export var map_size_tiles: int = 48
@export var courtyard_radius_tiles: int = 8
@export var door_width_tiles: int = 3
@export var hearth_max_health: float = 100.0

@onready var ground: TileMapLayer = $Ground
@onready var frames: Node2D = $Frames
@onready var entities: Node2D = $Entities
@onready var structures: Node2D = $Structures
@onready var hearth: StaticBody2D = $Entities/Hearth
@onready var player: CharacterBody2D = $Entities/Player
@onready var hearth_health: HealthComponent = $Entities/Hearth/HealthComponent
@onready var phase_manager: PhaseManager = $PhaseManager
@onready var inventory: PlayerInventory = $PlayerInventory
@onready var build_manager: BuildManager = $BuildManager
@onready var night_wave_manager: NightWaveManager = $NightWaveManager
@onready var hero_death_manager: HeroDeathManager = $HeroDeathManager
@onready var build_menu: BuildMenu = $HUD/BuildMenu
@onready var phase_label: Label = $HUD/PhaseLabel
@onready var inventory_label: Label = $HUD/InventoryLabel
@onready var door_marker: Node2D = $DoorMarker
@onready var camera: Camera2D = $Camera

var _end_screen_scene: PackedScene = preload("res://scenes/UI/end_screen.tscn")
var _run_ended: bool = false


func _ready() -> void:
	AchievementStore.begin_run()
	_build_ground()
	_build_frames()
	_place_entities()
	_strip_survivors_abilities()
	_ensure_player_combat()
	_wire_phase()
	_wire_build()
	_wire_night_wave()
	_wire_hero_death()
	_wire_hearth_death()
	_wire_achievements()
	_update_phase_label()
	_update_inventory_label()
	_update_weapon_label()
	_update_door_marker()


func get_center_tile() -> Vector2i:
	return Vector2i(map_size_tiles / 2, map_size_tiles / 2)


func get_courtyard_radius() -> int:
	return courtyard_radius_tiles


func get_map_center_world() -> Vector2:
	return _tile_to_world_center(get_center_tile())


func _ensure_player_combat() -> void:
	if player.get_node_or_null("PlayerCombat") != null:
		player.combat = player.get_node("PlayerCombat") as PlayerCombat
		return
	var combat_scene: PackedScene = load("res://scenes/game_object/player/player_combat.tscn")
	var combat := combat_scene.instantiate() as PlayerCombat
	combat.name = "PlayerCombat"
	player.add_child(combat)
	player.combat = combat
	combat.weapon_changed.connect(func(_w): _update_weapon_label())


func _wire_phase() -> void:
	phase_manager.phase_changed.connect(_on_phase_changed)
	phase_manager.active_door_chosen.connect(func(_side): _update_door_marker())


func _wire_build() -> void:
	build_manager.economy = load("res://resources/economy/build_economy.tres") as BuildEconomy
	build_manager.resource_node_scene = load("res://scenes/game_object/resource_node/resource_node.tscn")
	build_manager.player_wall_scene = load("res://scenes/game_object/player_wall/player_wall.tscn")
	build_manager.phase_manager = phase_manager
	build_manager.inventory = inventory
	build_manager.map_root = self
	build_manager.entities = entities
	build_manager.structures = structures
	build_manager.player = player
	build_manager.hearth = hearth
	build_manager.build_menu = build_menu
	inventory.changed.connect(_update_inventory_label)
	_ignore_hud_mouse()


func _ignore_hud_mouse() -> void:
	for label in [phase_label, inventory_label, get_node_or_null("HUD/WeaponLabel")]:
		if label is Control:
			(label as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE


func _wire_night_wave() -> void:
	night_wave_manager.wave_table = load("res://resources/waves/wave_table.tres") as WaveTable
	night_wave_manager.phase_manager = phase_manager
	night_wave_manager.map_root = self
	night_wave_manager.entities = entities


func _wire_hero_death() -> void:
	hero_death_manager.phase_manager = phase_manager
	hero_death_manager.player = player
	hero_death_manager.hearth = hearth
	hero_death_manager.camera = camera


func _wire_hearth_death() -> void:
	hearth_health.died.connect(_on_hearth_died)


func _wire_achievements() -> void:
	phase_manager.wave_cleared.connect(_on_wave_cleared_achievements)


func _on_wave_cleared_achievements() -> void:
	# `cleared_while_hero_down` is set by HeroDeathManager before/with wave_cleared handling.
	var while_down := (
		hero_death_manager.is_downed
		or hero_death_manager.cleared_wave_while_downed
		or phase_manager.cleared_while_hero_down
	)
	AchievementStore.evaluate_after_night(phase_manager.nights_survived, while_down)


func _on_hearth_died() -> void:
	if _run_ended:
		return
	_run_ended = true
	night_wave_manager.notify_run_ended()
	get_tree().paused = true
	var end_screen = _end_screen_scene.instantiate()
	end_screen.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	add_child(end_screen)
	end_screen.set_defeat()
	end_screen.show_run_summary(
		phase_manager.nights_survived,
		AchievementStore.newly_unlocked_this_run.duplicate()
	)


func _on_phase_changed(_phase: PhaseManager.Phase) -> void:
	_update_phase_label()


func _update_phase_label() -> void:
	phase_label.text = "Phase: %s  |  Door: %s  |  Nights: %d" % [
		phase_manager.get_phase_name(),
		phase_manager.get_door_name(),
		phase_manager.nights_survived,
	]
	phase_label.text += "  |  LMB attack  Space dash  B build  E interact"


func _update_inventory_label() -> void:
	inventory_label.text = "Wood: %d   Stone: %d   Scrap: %d" % [
		inventory.wood, inventory.stone, inventory.scrap
	]


func _update_weapon_label() -> void:
	var weapon_label := get_node_or_null("HUD/WeaponLabel") as Label
	if weapon_label == null:
		return
	var combat := player.get_node_or_null("PlayerCombat") as PlayerCombat
	if combat == null:
		weapon_label.text = "Weapon: —"
		return
	weapon_label.text = "Weapon: %s  (E at Weapon Stand to swap)" % combat.get_weapon_name()


func _update_door_marker() -> void:
	var pos := get_door_world_center(phase_manager.active_door)
	door_marker.global_position = pos
	for child in door_marker.get_children():
		child.queue_free()
	var marker := Polygon2D.new()
	marker.color = ACTIVE_DOOR_COLOR
	marker.polygon = PackedVector2Array([
		Vector2(-10, -10),
		Vector2(10, -10),
		Vector2(10, 10),
		Vector2(-10, 10),
	])
	door_marker.add_child(marker)
	var tag := Label.new()
	tag.text = "DOOR %s" % phase_manager.get_door_name()
	tag.position = Vector2(-18, -22)
	tag.add_theme_font_size_override("font_size", 8)
	door_marker.add_child(tag)


func _tile_to_world_center(tile: Vector2i) -> Vector2:
	return Vector2(tile) * TILE_SIZE + Vector2(TILE_SIZE, TILE_SIZE) * 0.5


func get_door_world_center(side: PhaseManager.DoorSide) -> Vector2:
	var c := get_center_tile()
	var left := c.x - courtyard_radius_tiles
	var right := c.x + courtyard_radius_tiles
	var top := c.y - courtyard_radius_tiles
	var bottom := c.y + courtyard_radius_tiles
	match side:
		PhaseManager.DoorSide.NORTH:
			return _tile_to_world_center(Vector2i(c.x, top))
		PhaseManager.DoorSide.SOUTH:
			return _tile_to_world_center(Vector2i(c.x, bottom))
		PhaseManager.DoorSide.WEST:
			return _tile_to_world_center(Vector2i(left, c.y))
		PhaseManager.DoorSide.EAST:
			return _tile_to_world_center(Vector2i(right, c.y))
	return _tile_to_world_center(c)


func _build_ground() -> void:
	for y in range(map_size_tiles):
		for x in range(map_size_tiles):
			ground.set_cell(Vector2i(x, y), GROUND_SOURCE_ID, GROUND_ATLAS)


func _build_frames() -> void:
	var c := get_center_tile()
	var left := c.x - courtyard_radius_tiles
	var right := c.x + courtyard_radius_tiles
	var top := c.y - courtyard_radius_tiles
	var bottom := c.y + courtyard_radius_tiles
	var half_door := int(door_width_tiles / 2.0)
	var door_lo := -half_door
	var door_hi := door_width_tiles - half_door

	_add_wall_segment(left, top, c.x + door_lo - left, 1)
	_add_wall_segment(c.x + door_hi, top, right - (c.x + door_hi) + 1, 1)
	_add_wall_segment(left, bottom, c.x + door_lo - left, 1)
	_add_wall_segment(c.x + door_hi, bottom, right - (c.x + door_hi) + 1, 1)
	_add_wall_segment(left, top + 1, 1, c.y + door_lo - (top + 1))
	_add_wall_segment(left, c.y + door_hi, 1, bottom - (c.y + door_hi))
	_add_wall_segment(right, top + 1, 1, c.y + door_lo - (top + 1))
	_add_wall_segment(right, c.y + door_hi, 1, bottom - (c.y + door_hi))


func _add_wall_segment(tile_x: int, tile_y: int, width_tiles: int, height_tiles: int) -> void:
	if width_tiles <= 0 or height_tiles <= 0:
		return

	var body := StaticBody2D.new()
	body.collision_layer = Layers.TERRAIN
	body.collision_mask = 0
	body.position = Vector2(tile_x, tile_y) * TILE_SIZE

	var size_px := Vector2(width_tiles, height_tiles) * TILE_SIZE

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size_px
	shape.shape = rect
	shape.position = size_px * 0.5
	body.add_child(shape)

	var visual := Polygon2D.new()
	visual.color = WALL_COLOR
	visual.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size_px.x, 0.0),
		size_px,
		Vector2(0.0, size_px.y),
	])
	body.add_child(visual)

	frames.add_child(body)


func _place_entities() -> void:
	var c := get_center_tile()
	var center_world := _tile_to_world_center(c)
	hearth.global_position = center_world
	hearth_health.max_health = hearth_max_health
	hearth_health.current_health = hearth_max_health
	player.global_position = center_world + Vector2(0, TILE_SIZE * 2)


func _strip_survivors_abilities() -> void:
	var abilities := player.get_node_or_null("Abilities")
	if abilities == null:
		return
	for child in abilities.get_children():
		child.queue_free()
