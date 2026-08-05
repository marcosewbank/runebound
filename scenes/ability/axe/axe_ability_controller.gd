extends BaseAbilityController

@export var axe_ability_scene: PackedScene


func _ready() -> void:
	base_cooldown = 3.0
	base_damage = 10.0
	super._ready()


func activate() -> void:
	if _player == null:
		_player = get_tree().get_first_node_in_group(Groups.PLAYER) as Node2D
	if _player == null or axe_ability_scene == null:
		return

	var foreground = get_tree().get_first_node_in_group(Groups.FOREGROUND_LAYER) as Node2D
	if foreground == null:
		return

	var axe_instance = axe_ability_scene.instantiate() as Node2D
	foreground.add_child(axe_instance)
	axe_instance.global_position = _player.global_position
	axe_instance.hitbox_component.damage = get_damage()
	axe_instance.hitbox_component.team = HitboxComponent.Team.PLAYER
