extends BaseCharacter

@export var class_hp: int = 80;
@export var class_mana: int = 120;
@export var class_speed: int = 8;
@export var class_damage: int = 15;

var char: BaseCharacter;

func _init() -> void:
	super._init(
		class_hp,
		class_mana,
		class_speed,
		class_damage,
		BaseCharacter.CustomClass.MAGE
	)
