extends CharacterBody2D

class_name BaseCharacter

var _name: String;
var _hp: int;
var _mana: int;
var _speed: int;
var _damage: int;

func _init(
	p_name: 	String	= "none",
	p_hp: 		int		= 100,
	p_mana: 	int		= 50,
	p_speed: 	int		= 2,
	p_damage: 	int 	= 10
) -> void:
	_name = 	p_name;
	_hp = 		p_hp;
	_mana = 	p_mana;
	_speed = 	p_speed;
	_damage = 	p_damage;

func level_up() -> void:
	pass

func take_damage() -> void:
	pass
