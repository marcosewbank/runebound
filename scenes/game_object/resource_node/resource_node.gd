extends Area2D
class_name ResourceNode
## Outside gather node. Instant pickup on E; refills at Dawn.

enum Kind { WOOD, STONE }

@export var kind: Kind = Kind.WOOD
@export var refill_amount: int = 3
@export var interact_radius: float = 20.0

var amount_left: int = 0
var _player_in_range: bool = false


func _ready() -> void:
	add_to_group(Groups.RESOURCE_NODE)
	collision_layer = 0
	collision_mask = Layers.PLAYER_BODY
	monitoring = true
	if not has_node("CollisionShape2D"):
		var shape := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = interact_radius
		shape.shape = circle
		add_child(shape)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	refill()
	_refresh_visual()


func refill() -> void:
	amount_left = refill_amount
	_refresh_visual()


func can_gather() -> bool:
	return _player_in_range and amount_left > 0


func gather(inventory: PlayerInventory) -> bool:
	if not can_gather():
		return false
	var took := amount_left
	amount_left = 0
	match kind:
		Kind.WOOD:
			inventory.add_wood(took)
		Kind.STONE:
			inventory.add_stone(took)
	_refresh_visual()
	return true


func _refresh_visual() -> void:
	var visual := get_node_or_null("Visual") as Polygon2D
	if visual == null:
		return
	visual.visible = amount_left > 0
	match kind:
		Kind.WOOD:
			visual.color = Color(0.45, 0.28, 0.12, 1.0)
		Kind.STONE:
			visual.color = Color(0.55, 0.58, 0.62, 1.0)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(Groups.PLAYER):
		_player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(Groups.PLAYER):
		_player_in_range = false
