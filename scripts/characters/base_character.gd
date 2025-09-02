extends CharacterBody2D

class_name BaseCharacter

var _name: 					String;
var _hp: 					int;
var _mana: 					int;
var _speed: 				int;
var _damage: 				int;
var _is_dead: 				bool = false;
var unnalloacted_points: 	int = 0;

func _init(
	p_name: 	String	= "none",
	p_hp: 		int		= 100,
	p_mana: 	int		= 50,
	p_speed: 	int		= 10,
	p_damage: 	int 	= 10
) -> void:
	_name = 	p_name;
	_hp = 		p_hp;
	_mana = 	p_mana;
	_speed = 	p_speed;
	_damage = 	p_damage;

func level_up() -> void:
	unnalloacted_points += 5;

func take_damage(damage: int) -> bool:
	_hp -= damage;
	if _hp < 0:
		_is_dead = true;
	return _is_dead

func _move() -> void:
	pass
