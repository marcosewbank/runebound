class_name Targeting
extends Object


static func get_enemies_in_range(tree: SceneTree, origin: Vector2, max_range: float) -> Array[Node2D]:
	var result: Array[Node2D] = []
	var max_range_squared = max_range * max_range
	for enemy in tree.get_nodes_in_group(Groups.ENEMY):
		if not enemy is Node2D:
			continue
		var node := enemy as Node2D
		if node.global_position.distance_squared_to(origin) <= max_range_squared:
			result.append(node)
	return result


static func get_nearest_enemy(tree: SceneTree, origin: Vector2, max_range: float = INF) -> Node2D:
	var nearest: Node2D = null
	var nearest_distance_squared := max_range * max_range
	for enemy in tree.get_nodes_in_group(Groups.ENEMY):
		if not enemy is Node2D:
			continue
		var node := enemy as Node2D
		var distance_squared = node.global_position.distance_squared_to(origin)
		if distance_squared < nearest_distance_squared:
			nearest = node
			nearest_distance_squared = distance_squared
	return nearest


## Nearest hero or destructible structure (player walls / hearth). Frames are not targets.
static func get_nearest_attack_target(tree: SceneTree, origin: Vector2, max_range: float = INF) -> Node2D:
	var nearest: Node2D = null
	var nearest_distance_squared := max_range * max_range
	for group_name in [Groups.PLAYER, Groups.PLAYER_WALL, Groups.HEARTH, Groups.BUILDING]:
		for node in tree.get_nodes_in_group(group_name):
			if not node is Node2D:
				continue
			var candidate := node as Node2D
			if not is_instance_valid(candidate):
				continue
			var health := candidate.get_node_or_null("HealthComponent") as HealthComponent
			if health != null and health.current_health <= 0:
				continue
			var distance_squared = candidate.global_position.distance_squared_to(origin)
			if distance_squared < nearest_distance_squared:
				nearest = candidate
				nearest_distance_squared = distance_squared
	return nearest
