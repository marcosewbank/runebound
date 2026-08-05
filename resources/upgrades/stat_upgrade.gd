extends AbilityUpgrade
class_name StatUpgrade

@export var stat_name: StringName = &"move_speed"
@export var modifier_type: StatNames.ModifierType = StatNames.ModifierType.PERCENT
@export var value_per_stack: float = 0.1
