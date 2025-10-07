extends CharacterBody2D

@onready var velocity_component = $VelocityComponent

func _process(_delta: float) -> void:
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
