extends StaticBody2D
class_name Hearth
## Central objective. Indestructible frames are separate; this node has HP.
## Interact (horn / repair) is routed by BuildManager.

@export var interact_radius: float = 40.0

@onready var health_component: HealthComponent = $HealthComponent


func _ready() -> void:
	add_to_group(Groups.HEARTH)
	collision_layer = Layers.TERRAIN
	collision_mask = 0
