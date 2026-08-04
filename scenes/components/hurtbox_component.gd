extends Area2D
class_name HurtboxComponent

enum Team { PLAYER, ENEMY }

@export var health_component: HealthComponent
@export var team: Team = Team.ENEMY
@export var invulnerability_time: float = 0.0

var floating_text_scene = preload("res://scenes/UI/floating_text.tscn")
var _invulnerable := false


func _ready() -> void:
	monitoring = true
	monitorable = false
	match team:
		Team.PLAYER:
			collision_layer = Layers.PLAYER_HURTBOX
			collision_mask = Layers.ENEMY_HITBOX
		Team.ENEMY:
			collision_layer = Layers.ENEMY_HURTBOX
			collision_mask = Layers.PLAYER_HITBOX
	area_entered.connect(on_area_entered)


func on_area_entered(other_area: Area2D) -> void:
	if _invulnerable:
		return
	if not other_area is HitboxComponent:
		return
	if health_component == null:
		return

	var hitbox_component = other_area as HitboxComponent
	# Player hitboxes damage enemy hurtboxes; enemy hitboxes damage player hurtboxes.
	if team == Team.PLAYER and hitbox_component.team != HitboxComponent.Team.ENEMY:
		return
	if team == Team.ENEMY and hitbox_component.team != HitboxComponent.Team.PLAYER:
		return

	health_component.damage(hitbox_component.damage)

	var floating_text = floating_text_scene.instantiate() as Node2D
	get_tree().get_first_node_in_group(Groups.FOREGROUND_LAYER).add_child(floating_text)
	floating_text.global_position = global_position + (Vector2.UP * 16)
	floating_text.start(str(hitbox_component.damage))

	if invulnerability_time > 0.0:
		_invulnerable = true
		get_tree().create_timer(invulnerability_time).timeout.connect(_on_invulnerability_ended)


func _on_invulnerability_ended() -> void:
	_invulnerable = false
	for area in get_overlapping_areas():
		on_area_entered(area)
