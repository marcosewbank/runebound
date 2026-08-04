extends Resource
class_name WaveTable
## Night wave composition. Slice 4: slime-only; escalate count by nights survived.

@export var enemy_scene: PackedScene
@export var base_count: int = 4
@export var count_per_night: int = 2
@export var spawn_interval: float = 0.4


func enemy_count_for_night(nights_already_survived: int) -> int:
	return base_count + nights_already_survived * count_per_night
