extends BaseCharacter

@export var class_hp: int = 90;
@export var class_mana: int = 90;
@export var class_speed: int = 12;
@export var class_damage: int = 12;

var char: BaseCharacter;

func _init() -> void:
	super._init(
		class_hp,
		class_mana,
		class_speed,
		class_damage
	)

