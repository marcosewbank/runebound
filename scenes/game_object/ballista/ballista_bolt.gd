extends Node2D
class_name BallistaBolt
## Weak chip projectile from a ballista.

@export var speed: float = 160.0
@export var lifetime: float = 0.9

@onready var hitbox_component: HitboxComponent = $HitboxComponent

var direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	z_index = 15
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	rotation = direction.angle()
