extends StaticBody2D
class_name WeaponStand
## Placeable rack. E while nearby cycles the hero's equipped weapon.

@export var interact_radius: float = 24.0

@onready var health_component: HealthComponent = $HealthComponent

var _player_in_range: bool = false


func _ready() -> void:
	add_to_group(Groups.WEAPON_STAND)
	add_to_group(Groups.BUILDING)
	collision_layer = Layers.TERRAIN
	collision_mask = 0
	_ensure_interact_area()
	if health_component != null:
		health_component.died.connect(queue_free)


func can_swap() -> bool:
	return _player_in_range


func _ensure_interact_area() -> void:
	if has_node("InteractArea"):
		return
	var area := Area2D.new()
	area.name = "InteractArea"
	area.collision_layer = 0
	area.collision_mask = Layers.PLAYER_BODY
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = interact_radius
	shape.shape = circle
	area.add_child(shape)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	add_child(area)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(Groups.PLAYER):
		_player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(Groups.PLAYER):
		_player_in_range = false
