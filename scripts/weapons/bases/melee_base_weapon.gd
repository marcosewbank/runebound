extends BaseWeapon

class_name MeleeBaseWeapon

const base_damage: int = 2
var w_damage: int = 0

func _init():
	if w_damage == 0:
		push_error("Weapon doesnt have the weapon damage")
		return

	damage += base_damage * w_damage

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node):
	if body.has_method("take_damage"):
		body.take_damage(damage)

func _action():
	print("bumm")
