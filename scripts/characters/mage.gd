extends BaseCharacter

@export var c_name: String = "mage"
@export var c_hp: int = 80;
@export var c_mana: int = 120;
@export var c_speed: int = 8;
@export var c_damage: int = 15;

var char: BaseCharacter;

func _init() -> void:
	super._init(
		c_name,
		c_hp,
		c_mana,
		c_speed,
		c_damage,
		BaseCharacter.CustomClass.MAGE
	)
