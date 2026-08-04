extends Node2D
class_name StaffProjectile
## Aimed staff bolt — visible orb + player hitbox.

@export var speed: float = 240.0
@export var lifetime: float = 1.0

@onready var hitbox_component: HitboxComponent = $HitboxComponent

var direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	z_index = 20
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	rotation = direction.angle()
	# Manual wall probe — stop on terrain bodies.
	var space := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = global_position
	query.collision_mask = Layers.TERRAIN
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var hits := space.intersect_point(query, 4)
	for hit in hits:
		var collider = hit.get("collider")
		if collider != null and not collider.is_in_group(Groups.PLAYER):
			queue_free()
			return
