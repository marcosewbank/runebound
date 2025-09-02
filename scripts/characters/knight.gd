extends BaseCharacter

@export var c_name: String = "knight"
@export var c_hp: int = 150;
@export var c_mana: int = 20;
@export var c_speed: int = 10;
@export var c_damage: int = 12;

var char: BaseCharacter;

func _init() -> void:
	super._init(
		c_name,
		c_hp,
		c_mana,
		c_speed,
		c_damage,
		BaseCharacter.CustomClass.KNIGHT
	)
