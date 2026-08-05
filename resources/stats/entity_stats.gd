class_name EntityStats
extends Resource

@export var max_health: float = 10.0
@export var move_speed: float = 40.0
@export var acceleration: float = 5.0
@export var damage: float = 1.0
@export var attack_rate: float = 1.0
@export var pickup_radius: float = 29.0
@export var armor: float = 0.0


func get_base(stat: StringName) -> float:
	match stat:
		StatNames.MAX_HEALTH:
			return max_health
		StatNames.MOVE_SPEED:
			return move_speed
		StatNames.ACCELERATION:
			return acceleration
		StatNames.DAMAGE:
			return damage
		StatNames.ATTACK_RATE:
			return attack_rate
		StatNames.PICKUP_RADIUS:
			return pickup_radius
		StatNames.ARMOR:
			return armor
		_:
			push_error("Unknown stat: %s" % stat)
			return 0.0
