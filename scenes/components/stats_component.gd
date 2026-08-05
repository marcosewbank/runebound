extends Node
class_name StatsComponent

signal stat_changed(stat_name: StringName)

@export var base_stats: EntityStats

## source_id -> Array[{stat: StringName, type: int, value: float}]
var _modifiers: Dictionary = {}


func get_stat(stat_name: StringName) -> float:
	var base := 0.0
	if base_stats != null:
		base = base_stats.get_base(stat_name)

	var flat := 0.0
	var percent := 0.0
	for source_id in _modifiers:
		for modifier in _modifiers[source_id]:
			if modifier.stat != stat_name:
				continue
			match modifier.type:
				StatNames.ModifierType.FLAT:
					flat += modifier.value
				StatNames.ModifierType.PERCENT:
					percent += modifier.value

	return (base + flat) * (1.0 + percent)


func add_modifier(source_id: String, stat_name: StringName, type: StatNames.ModifierType, value: float) -> void:
	if not _modifiers.has(source_id):
		_modifiers[source_id] = []

	_modifiers[source_id].append({
		"stat": stat_name,
		"type": type,
		"value": value,
	})
	stat_changed.emit(stat_name)


func set_modifier(source_id: String, stat_name: StringName, type: StatNames.ModifierType, value: float) -> void:
	remove_modifier_for_stat(source_id, stat_name)
	add_modifier(source_id, stat_name, type, value)


func remove_modifier(source_id: String) -> void:
	if not _modifiers.has(source_id):
		return

	var affected_stats: Dictionary = {}
	for modifier in _modifiers[source_id]:
		affected_stats[modifier.stat] = true

	_modifiers.erase(source_id)
	for stat_name in affected_stats:
		stat_changed.emit(stat_name)


func remove_modifier_for_stat(source_id: String, stat_name: StringName) -> void:
	if not _modifiers.has(source_id):
		return

	var remaining: Array = []
	var removed := false
	for modifier in _modifiers[source_id]:
		if modifier.stat == stat_name:
			removed = true
			continue
		remaining.append(modifier)

	if remaining.is_empty():
		_modifiers.erase(source_id)
	else:
		_modifiers[source_id] = remaining

	if removed:
		stat_changed.emit(stat_name)
