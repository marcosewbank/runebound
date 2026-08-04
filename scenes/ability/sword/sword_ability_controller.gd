extends BaseAbilityController

const MAX_RANGE = 200

@export var sword_ability: PackedScene


func _ready() -> void:
	base_cooldown = 1.0
	base_damage = 5.0
	super._ready()


func activate() -> void:
	if _player == null:
		_player = get_tree().get_first_node_in_group(Groups.PLAYER) as Node2D
	if _player == null or sword_ability == null:
		return

	var nearest = Targeting.get_nearest_enemy(get_tree(), _player.global_position, MAX_RANGE)
	if nearest == null:
		return

	var sword_instance = sword_ability.instantiate() as SwordAbility
	var foreground = get_tree().get_first_node_in_group(Groups.FOREGROUND_LAYER)
	foreground.add_child(sword_instance)

	sword_instance.hitbox_component.damage = get_damage()
	sword_instance.hitbox_component.team = HitboxComponent.Team.PLAYER

	sword_instance.global_position = nearest.global_position
	sword_instance.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * 4

	var enemy_direction = nearest.global_position - sword_instance.global_position
	sword_instance.rotation = enemy_direction.angle()
