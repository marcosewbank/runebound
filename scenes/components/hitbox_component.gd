extends Area2D
class_name HitboxComponent

enum Team { PLAYER, ENEMY }

@export var team: Team = Team.PLAYER
@export var damage: float = 0.0


func _ready() -> void:
	monitoring = false
	monitorable = true
	collision_mask = 0
	match team:
		Team.PLAYER:
			collision_layer = Layers.PLAYER_HITBOX
		Team.ENEMY:
			collision_layer = Layers.ENEMY_HITBOX
