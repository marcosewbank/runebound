extends Resource
class_name BuildingDef
## Catalog entry for the build panel.

@export var id: StringName = &""
@export var display_name: String = ""
@export var description: String = ""
@export var wood_cost: int = 0
@export var stone_cost: int = 0
@export var scene: PackedScene
@export var ghost_color: Color = Color(0.55, 0.38, 0.18, 0.5)
