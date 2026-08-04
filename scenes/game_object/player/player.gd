extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: ProgressBar = $HealthBar
@onready var abilities: Node = $Abilities
@onready var stats_component: StatsComponent = $StatsComponent

var combat: PlayerCombat


func _ready():
	health_component.health_changed.connect(on_health_changed)
	health_component.died.connect(on_died)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	stats_component.stat_changed.connect(on_stat_changed)
	combat = get_node_or_null("PlayerCombat") as PlayerCombat
	_apply_stats()
	update_health_display()


func on_died() -> void:
	# HeroDeathManager owns downed / day-death flow. Do not free the player.
	pass


func _physics_process(delta: float) -> void:
	if combat != null and combat.is_dashing():
		velocity = combat.get_dash_velocity()
		move_and_slide()
		return
	_get_direction_input(delta)
	move_and_slide()


func _get_direction_input(delta: float):
	var direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var target_velocity = direction * stats_component.get_stat(StatNames.MOVE_SPEED)
	var smoothing = stats_component.get_stat(StatNames.ACCELERATION)
	velocity = velocity.lerp(target_velocity, 1 - exp(-delta * smoothing))


func _apply_stats() -> void:
	health_component.max_health = stats_component.get_stat(StatNames.MAX_HEALTH)
	health_component.current_health = health_component.max_health
	var pickup_shape = $PickupArea2D/CollisionShape2D.shape as CircleShape2D
	if pickup_shape != null:
		pickup_shape.radius = stats_component.get_stat(StatNames.PICKUP_RADIUS)


func on_stat_changed(stat_name: StringName) -> void:
	match stat_name:
		StatNames.MAX_HEALTH:
			var percent = health_component.get_health_percent()
			health_component.max_health = stats_component.get_stat(StatNames.MAX_HEALTH)
			health_component.current_health = health_component.max_health * percent
			health_component.health_changed.emit()
		StatNames.PICKUP_RADIUS:
			var pickup_shape = $PickupArea2D/CollisionShape2D.shape as CircleShape2D
			if pickup_shape != null:
				pickup_shape.radius = stats_component.get_stat(StatNames.PICKUP_RADIUS)


func update_health_display():
	health_bar.value = health_component.get_health_percent()


func on_health_changed():
	update_health_display()


func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if ability_upgrade is Ability:
		var ability = ability_upgrade as Ability
		abilities.add_child(ability.ability_controller_scene.instantiate())
		return

	if ability_upgrade is StatUpgrade:
		var stat_upgrade = ability_upgrade as StatUpgrade
		var quantity = current_upgrades[stat_upgrade.id]["quantity"]
		var value = stat_upgrade.value_per_stack * quantity
		stats_component.set_modifier(
			stat_upgrade.id,
			stat_upgrade.stat_name,
			stat_upgrade.modifier_type,
			value
		)
