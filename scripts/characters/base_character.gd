extends CharacterBody2D

class_name BaseCharacter

enum CustomClass {
	KNIGHT 	= 	0,
	MAGE	=	1,
	RANGER	=	2,
	ENEMY	=	3,
	BOSS	=	4,
	NONE	= 	5
}

var _name: 					String;
var _hp: 					int;
var _mana: 					int;
var _speed: 				int;
var _damage: 				int;
var _is_dead: 				bool = false;
var _class_type:			int;
var _unnalloacted_points: 	int = 0;
var _points_per_level:		int = 5;

const SPEED = 300.0

func _init(
	p_name: 		String	= "none",
	p_hp: 			int		= 100,
	p_mana: 		int		= 50,
	p_speed: 		int		= 10,
	p_damage: 		int 	= 10,
	p_class_type: 	int		= CustomClass.NONE
) -> void:
	_name 		= 	p_name;
	_hp 		= 	p_hp;
	_mana 		= 	p_mana;
	_speed 		= 	p_speed;
	_damage 	= 	p_damage;
	_class_type	=	p_class_type;

func level_up() -> void: 
	match _class_type:
		CustomClass.ENEMY, CustomClass.BOSS:
			pass #mobs dont level up
		_:
			_unnalloacted_points += _points_per_level;

func take_damage(damage: int) -> bool:
	_hp -= damage;
	if _hp < 0:
		_is_dead = true;
	return _is_dead


func _get_direction_input():
	var direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	velocity = direction * SPEED

func _physics_process(_delta: float) -> void:
	match _class_type:
		CustomClass.ENEMY, CustomClass.BOSS:
			pass
		_:
			_get_direction_input()
			move_and_slide()

