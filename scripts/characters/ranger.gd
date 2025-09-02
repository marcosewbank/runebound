extends BaseCharacter

@export var c_name: String = "ranger"
@export var c_hp: int = 90;
@export var c_mana: int = 90;
@export var c_speed: int = 12;
@export var c_damage: int = 12;

var char: BaseCharacter;

func _init() -> void:
	super._init(
		c_name,
		c_hp,
		c_mana,
		c_speed,
		c_damage,
		BaseCharacter.CustomClass.RANGER
	)
