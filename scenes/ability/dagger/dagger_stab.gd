extends Node2D
## High single-target burst stab toward aim direction.

@onready var hitbox_component: HitboxComponent = $HitboxComponent


func _ready() -> void:
	z_index = 20
	var tween := create_tween()
	tween.tween_property($StabFx, "modulate:a", 0.0, 0.12)
	tween.parallel().tween_interval(0.14)
	tween.tween_callback(queue_free)
