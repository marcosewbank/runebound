extends CharacterBody2D
class_name BaseEnemy

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var stats_component: StatsComponent = $StatsComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent


func _ready() -> void:
	health_component.died.connect(on_died)
	_apply_stats()


func _physics_process(_delta: float) -> void:
	velocity_component.accelerate_to_nearest_target()
	velocity_component.move(self)


func _apply_stats() -> void:
	var max_health = stats_component.get_stat(StatNames.MAX_HEALTH)
	health_component.max_health = max_health
	health_component.current_health = max_health

	velocity_component.max_speed = int(stats_component.get_stat(StatNames.MOVE_SPEED))
	velocity_component.acceleration = stats_component.get_stat(StatNames.ACCELERATION)

	hitbox_component.damage = stats_component.get_stat(StatNames.DAMAGE)
	hitbox_component.team = HitboxComponent.Team.ENEMY


func on_died() -> void:
	# ExperienceComponent already reacted to died (connected in its _ready first).
	_drop_scrap()
	queue_free()


func _drop_scrap() -> void:
	for node in get_tree().get_nodes_in_group(Groups.PLAYER_INVENTORY):
		if node is PlayerInventory:
			(node as PlayerInventory).add_scrap(1)
			return
