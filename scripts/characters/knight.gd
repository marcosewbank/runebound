extends BaseCharacter

@export var class_hp: int = 150;
@export var class_mana: int = 20;
@export var class_speed: int = 10;
@export var class_damage: int = 12;

var char: BaseCharacter;

func _init() -> void:
	super._init(
		class_hp,
		class_mana,
		class_speed,
		class_damage
	)
