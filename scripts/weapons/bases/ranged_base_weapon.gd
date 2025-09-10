extends BaseWeapon

class_name RangedBaseWeapon

const BULLET = preload("res://scenes/ammo.tscn")

@onready var shooting_point: Marker2D = $WeaponPivot/Wand/ShootingPoint

func _process(_delta: float) -> void:
	look_at(get_global_mouse_position()	) 

	rotation_degrees = wrap(rotation_degrees, 0, 360)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1
	else:
		scale.y = 1

func _action():
	var bullet_instance = BULLET.instantiate()
	get_tree().root.add_child(bullet_instance)
	bullet_instance.global_position = shooting_point.global_position
	bullet_instance.rotation = rotation
