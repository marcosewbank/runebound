extends Area2D
class_name HitboxComponent

enum Team { PLAYER, ENEMY }

@export var team: Team = Team.PLAYER
@export var damage: float = 0.0

var _hit_ids: Dictionary = {}


func _ready() -> void:
	_apply_team_collision()
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)


func _apply_team_collision() -> void:
	match team:
		Team.PLAYER:
			# Actively strike enemy hurtboxes (more reliable for short-lived attack VFX).
			collision_layer = Layers.PLAYER_HITBOX
			collision_mask = Layers.ENEMY_HURTBOX
			monitoring = true
			monitorable = true
		Team.ENEMY:
			collision_layer = Layers.ENEMY_HITBOX
			collision_mask = 0
			monitoring = false
			monitorable = true


func _on_area_entered(other: Area2D) -> void:
	if team != Team.PLAYER:
		return
	if not other is HurtboxComponent:
		return
	var hurtbox := other as HurtboxComponent
	if hurtbox.team != HurtboxComponent.Team.ENEMY:
		return
	if hurtbox.health_component == null:
		return
	var id := hurtbox.get_instance_id()
	if _hit_ids.has(id):
		return
	_hit_ids[id] = true
	hurtbox.health_component.damage(damage)
