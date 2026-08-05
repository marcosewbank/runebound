extends StaticBody2D
class_name Ballista
## Weak chip turret. Must not clear a slime wave alone.

@export var fire_range: float = 120.0
@export var fire_interval: float = 1.4
@export var bolt_damage: float = 1.0
@export var bolt_scene: PackedScene

@onready var health_component: HealthComponent = $HealthComponent

var _cooldown: float = 0.0


func _ready() -> void:
	add_to_group(Groups.BUILDING)
	collision_layer = Layers.TERRAIN
	collision_mask = 0
	if bolt_scene == null:
		bolt_scene = load("res://scenes/game_object/ballista/ballista_bolt.tscn")
	if health_component != null:
		health_component.died.connect(queue_free)


func _physics_process(delta: float) -> void:
	_cooldown = max(_cooldown - delta, 0.0)
	if _cooldown > 0.0:
		return
	var target := Targeting.get_nearest_enemy(get_tree(), global_position, fire_range)
	if target == null:
		return
	_fire_at(target)
	_cooldown = fire_interval


func _fire_at(target: Node2D) -> void:
	if bolt_scene == null:
		return
	var parent := get_tree().get_first_node_in_group(Groups.ENTITIES_LAYER) as Node2D
	if parent == null:
		parent = get_parent() as Node2D
	var bolt := bolt_scene.instantiate() as Node2D
	parent.add_child(bolt)
	var aim := (target.global_position - global_position).normalized()
	bolt.global_position = global_position + aim * 8.0
	if bolt.get("direction") != null:
		bolt.set("direction", aim)
	var hitbox := bolt.get_node_or_null("HitboxComponent") as HitboxComponent
	if hitbox != null:
		hitbox.damage = bolt_damage
		hitbox.team = HitboxComponent.Team.PLAYER
		hitbox._apply_team_collision()
