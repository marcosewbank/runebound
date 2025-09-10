extends Area2D

class_name BaseWeapon

func _process(_delta: float) -> void:
	look_at(get_global_mouse_position()	) 
	
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1
	else:
		scale.y = 1

	if Input.is_action_just_pressed("shoot"):
		_action()
	
func _action():
	# implementation should be done for each extension of this class
	# not here
	# push an error if this class is instatiated because should be
	# used as a "abstract" method
	push_error("not implemented")
