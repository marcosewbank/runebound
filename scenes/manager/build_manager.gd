extends Node
class_name BuildManager
## Gather / place / repair. Place uses BuildMenu selection (Day only).

const TILE_SIZE := 16
const GHOST_OK := Color(0.3, 0.9, 0.35, 0.45)
const GHOST_BAD := Color(0.9, 0.25, 0.2, 0.45)

@export var economy: BuildEconomy
@export var resource_node_scene: PackedScene
@export var player_wall_scene: PackedScene
@export var phase_manager: PhaseManager
@export var inventory: PlayerInventory
@export var map_root: Node
@export var entities: Node2D
@export var structures: Node2D
@export var player: Node2D
@export var hearth: Node2D

var build_menu: BuildMenu
var selected_building: BuildingDef

var _ghost: Polygon2D
var _occupied: Dictionary = {}  # Vector2i -> Node
var player_combat: PlayerCombat


func _ready() -> void:
	if economy == null:
		economy = load("res://resources/economy/build_economy.tres") as BuildEconomy
	_ghost = Polygon2D.new()
	_ghost.polygon = PackedVector2Array([
		Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8),
	])
	_ghost.z_index = 5
	add_child(_ghost)
	call_deferred("_bootstrap")


func _bootstrap() -> void:
	_spawn_resource_nodes()
	if phase_manager != null:
		phase_manager.phase_changed.connect(_on_phase_changed)
	if hearth != null:
		hearth.add_to_group(Groups.HEARTH)
	if player != null:
		player_combat = player.get_node_or_null("PlayerCombat") as PlayerCombat
	if build_menu != null:
		build_menu.building_selected.connect(_on_building_selected)
		selected_building = build_menu.get_selected()


func _on_building_selected(def: BuildingDef) -> void:
	selected_building = def


func _process(_delta: float) -> void:
	_update_ghost()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if _try_interact():
			get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_F:
			_debug_damage_nearest()
			get_viewport().set_input_as_handled()


func _on_phase_changed(phase: PhaseManager.Phase) -> void:
	if phase == PhaseManager.Phase.DAWN:
		_refill_resource_nodes()
	_update_ghost()


func _try_interact() -> bool:
	# Priority: gather → repair wall → weapon stand swap → hearth repair/horn → place
	for node in get_tree().get_nodes_in_group(Groups.RESOURCE_NODE):
		var res := node as ResourceNode
		if res != null and res.can_gather():
			return res.gather(inventory)

	for node in get_tree().get_nodes_in_group(Groups.PLAYER_WALL):
		var wall := node as PlayerWall
		if wall != null and wall.can_repair():
			return _repair_wall(wall)

	for node in get_tree().get_nodes_in_group(Groups.WEAPON_STAND):
		var stand := node as WeaponStand
		if stand != null and stand.can_swap() and player_combat != null:
			player_combat.cycle_weapon()
			return true

	if _hearth_player_in_range():
		if hearth_health().is_damaged():
			return _repair_hearth()
		if phase_manager != null and phase_manager.phase == PhaseManager.Phase.DAY:
			phase_manager.sound_horn()
			return true
		return false

	return _try_place_at_mouse()


func _try_place_at_mouse() -> bool:
	if phase_manager == null or phase_manager.phase != PhaseManager.Phase.DAY:
		return false
	if selected_building == null or selected_building.scene == null:
		return false
	var tile := _mouse_tile()
	if not can_place_at(tile):
		return false
	if not _can_afford(selected_building):
		return false
	if not _spend(selected_building):
		return false
	_place_building(selected_building, tile)
	return true


func _can_afford(def: BuildingDef) -> bool:
	return inventory.wood >= def.wood_cost and inventory.stone >= def.stone_cost


func _spend(def: BuildingDef) -> bool:
	if def.wood_cost > 0 and not inventory.try_spend_wood(def.wood_cost):
		return false
	if def.stone_cost > 0 and not inventory.try_spend_stone(def.stone_cost):
		# refund wood if stone failed after wood spent
		if def.wood_cost > 0:
			inventory.add_wood(def.wood_cost)
		return false
	return true


func can_place_at(tile: Vector2i) -> bool:
	if not is_buildable_tile(tile):
		return false
	if _occupied.has(tile):
		return false
	var hearth_tile := _world_to_tile(hearth.global_position)
	if tile == hearth_tile:
		return false
	return true


func is_buildable_tile(tile: Vector2i) -> bool:
	var c: Vector2i = map_root.call("get_center_tile")
	var r: int = map_root.call("get_courtyard_radius")
	return tile.x > c.x - r and tile.x < c.x + r and tile.y > c.y - r and tile.y < c.y + r


func _place_building(def: BuildingDef, tile: Vector2i) -> void:
	var node := def.scene.instantiate() as Node2D
	node.global_position = _tile_to_world_center(tile)
	structures.add_child(node)
	if node is PlayerWall:
		var wall := node as PlayerWall
		wall.grid_tile = tile
		wall.health_component.max_health = economy.wall_max_health
		wall.health_component.current_health = economy.wall_max_health
	_occupied[tile] = node
	node.tree_exiting.connect(func(): _occupied.erase(tile))


func _repair_wall(wall: PlayerWall) -> bool:
	if not inventory.try_spend_wood(economy.wall_repair_wood_cost):
		return false
	wall.health_component.heal(wall.health_component.max_health)
	return true


func _repair_hearth() -> bool:
	if not inventory.try_spend_stone(economy.hearth_repair_stone_cost):
		return false
	hearth_health().heal(economy.hearth_repair_amount)
	return true


func hearth_health() -> HealthComponent:
	return hearth.get_node("HealthComponent") as HealthComponent


func _hearth_player_in_range() -> bool:
	if hearth == null or player == null:
		return false
	var radius: float = 40.0
	if hearth.get("interact_radius") != null:
		radius = float(hearth.interact_radius)
	return player.global_position.distance_to(hearth.global_position) <= radius


func _spawn_resource_nodes() -> void:
	if resource_node_scene == null or map_root == null:
		return
	var c: Vector2i = map_root.call("get_center_tile")
	var r: int = map_root.call("get_courtyard_radius")
	var spots: Array = [
		[Vector2i(c.x - r - 3, c.y - 2), ResourceNode.Kind.WOOD],
		[Vector2i(c.x + r + 3, c.y - 2), ResourceNode.Kind.WOOD],
		[Vector2i(c.x - 2, c.y - r - 3), ResourceNode.Kind.WOOD],
		[Vector2i(c.x + 2, c.y + r + 3), ResourceNode.Kind.STONE],
		[Vector2i(c.x - r - 3, c.y + 2), ResourceNode.Kind.STONE],
		[Vector2i(c.x + r + 3, c.y + 2), ResourceNode.Kind.STONE],
	]
	for spot in spots:
		var tile: Vector2i = spot[0]
		var kind: ResourceNode.Kind = spot[1]
		var node := resource_node_scene.instantiate() as ResourceNode
		node.kind = kind
		node.refill_amount = (
			economy.wood_node_amount if kind == ResourceNode.Kind.WOOD else economy.stone_node_amount
		)
		node.global_position = _tile_to_world_center(tile)
		var tag := node.get_node_or_null("Tag") as Label
		if tag != null:
			tag.text = "WOOD" if kind == ResourceNode.Kind.WOOD else "STONE"
		entities.add_child(node)


func _refill_resource_nodes() -> void:
	for node in get_tree().get_nodes_in_group(Groups.RESOURCE_NODE):
		var res := node as ResourceNode
		if res != null:
			res.refill_amount = (
				economy.wood_node_amount
				if res.kind == ResourceNode.Kind.WOOD
				else economy.stone_node_amount
			)
			res.refill()


func _update_ghost() -> void:
	if _ghost == null or inventory == null or phase_manager == null:
		return
	var day := phase_manager.phase == PhaseManager.Phase.DAY
	if not day or selected_building == null:
		_ghost.visible = false
		return
	var tile := _mouse_tile()
	_ghost.visible = true
	_ghost.global_position = _tile_to_world_center(tile)
	var affordable := _can_afford(selected_building)
	var can := can_place_at(tile) and affordable
	_ghost.color = selected_building.ghost_color if can else GHOST_BAD
	if can:
		_ghost.color.a = 0.55


func _debug_damage_nearest() -> void:
	var best: Node2D = null
	var best_dist := INF
	var origin: Vector2 = player.global_position
	for group_name in [Groups.PLAYER_WALL, Groups.BUILDING]:
		for node in get_tree().get_nodes_in_group(group_name):
			var building := node as Node2D
			if building == null:
				continue
			var d := origin.distance_to(building.global_position)
			if d < best_dist:
				best_dist = d
				best = building
	if best_dist > 64.0:
		hearth_health().damage(economy.debug_damage_amount)
		return
	var hc := best.get_node("HealthComponent") as HealthComponent
	if hc != null:
		hc.damage(economy.debug_damage_amount)


func _mouse_tile() -> Vector2i:
	return _world_to_tile(player.get_global_mouse_position())


func _world_to_tile(world: Vector2) -> Vector2i:
	return Vector2i(floori(world.x / TILE_SIZE), floori(world.y / TILE_SIZE))


func _tile_to_world_center(tile: Vector2i) -> Vector2:
	return Vector2(tile) * TILE_SIZE + Vector2(TILE_SIZE, TILE_SIZE) * 0.5
