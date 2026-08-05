extends Area2D
class_name FloorTrap
## Floor hazard: periodic chip damage + slow. Not a soak target.

@export var chip_damage: float = 1.0
@export var tick_interval: float = 0.85
@export var slow_multiplier: float = 0.45
@export var slow_duration: float = 0.7

var _cooldown: float = 0.0
var _bodies: Dictionary = {}


func _ready() -> void:
	z_index = -1
	collision_layer = 0
	collision_mask = Layers.ENEMY_BODY
	monitoring = true
	monitorable = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	_cooldown = max(_cooldown - delta, 0.0)
	if _cooldown > 0.0 or _bodies.is_empty():
		return
	_cooldown = tick_interval
	var stale: Array = []
	for id in _bodies.keys():
		var body: Node = _bodies[id]
		if not is_instance_valid(body):
			stale.append(id)
			continue
		_tick_enemy(body)
	for id in stale:
		_bodies.erase(id)


func _on_body_entered(body: Node) -> void:
	if body is BaseEnemy:
		_bodies[body.get_instance_id()] = body


func _on_body_exited(body: Node) -> void:
	_bodies.erase(body.get_instance_id())


func _tick_enemy(body: Node) -> void:
	var health := body.get_node_or_null("HealthComponent") as HealthComponent
	if health != null and health.current_health > 0.0:
		health.damage(chip_damage)
	var velocity := body.get_node_or_null("VelocityComponent") as VelocityComponent
	if velocity != null:
		velocity.apply_slow(slow_multiplier, slow_duration)
