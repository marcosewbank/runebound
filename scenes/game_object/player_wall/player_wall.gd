extends StaticBody2D
class_name PlayerWall
## Destructible player-built wooden wall. Place Day-only; repair Day+Night.

@export var interact_radius: float = 22.0

@onready var health_component: HealthComponent = $HealthComponent

var grid_tile: Vector2i = Vector2i.ZERO
var _player_in_range: bool = false


func _ready() -> void:
	add_to_group(Groups.PLAYER_WALL)
	collision_layer = Layers.TERRAIN
	collision_mask = 0
	_ensure_interact_area()
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	_on_health_changed()


func can_repair() -> bool:
	return _player_in_range and health_component.is_damaged() and health_component.current_health > 0


func _ensure_interact_area() -> void:
	if has_node("InteractArea"):
		return
	var area := Area2D.new()
	area.name = "InteractArea"
	area.collision_layer = 0
	area.collision_mask = Layers.PLAYER_BODY
	area.monitoring = true
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = interact_radius
	shape.shape = circle
	area.add_child(shape)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	add_child(area)


func _on_health_changed() -> void:
	var visual := get_node_or_null("Visual") as Polygon2D
	if visual == null:
		return
	var pct: float = health_component.get_health_percent()
	visual.color = Color(0.55, 0.38, 0.18, 0.45 + 0.55 * pct)


func _on_died() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(Groups.PLAYER):
		_player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(Groups.PLAYER):
		_player_in_range = false
