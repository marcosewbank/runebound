extends BaseCharacter

@export var class_hp: int = 100;
@export var class_mana: int = 50;
@export var class_speed: int = 2;
@export var class_damage: int = 10;

var char: BaseCharacter;

func _init() -> void:
	super._init(
		class_hp,
		class_mana,
		class_speed,
		class_damage
	)

