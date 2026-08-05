extends Node2D
## Short-lived aimed cleave arc in front of the player.

@onready var hitbox_component: HitboxComponent = $HitboxComponent


func _ready() -> void:
	z_index = 20
	var tween := create_tween()
	tween.tween_property($SlashFx, "modulate:a", 0.0, 0.2)
	tween.parallel().tween_interval(0.22)
	tween.tween_callback(queue_free)
