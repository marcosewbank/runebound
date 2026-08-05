extends Node
## Persistent achievement flags for base-defense runs.

const SAVE_PATH := "user://runebound_achievements.cfg"


const NIGHT_1 := &"survived_night_1"
const NIGHT_3 := &"survived_night_3"
const NIGHT_5 := &"survived_night_5"
const DAY_DEATH := &"died_during_day"
const CLEAR_WHILE_DOWN := &"cleared_while_down"

const DISPLAY_NAMES := {
	NIGHT_1: "Survived Night 1",
	NIGHT_3: "Survived Night 3",
	NIGHT_5: "Survived Night 5",
	DAY_DEATH: "Died During Day",
	CLEAR_WHILE_DOWN: "Cleared a Night While Down",
}

var unlocked: Dictionary = {}
## Unlocks that happened during the current run (for end-screen “new”).
var newly_unlocked_this_run: Array[StringName] = []


func _ready() -> void:
	load_from_disk()


func load_from_disk() -> void:
	unlocked.clear()
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	for key in DISPLAY_NAMES.keys():
		if cfg.get_value("achievements", String(key), false):
			unlocked[key] = true


func save_to_disk() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)  # keep unknown keys if any
	for key in DISPLAY_NAMES.keys():
		cfg.set_value("achievements", String(key), unlocked.has(key))
	cfg.save(SAVE_PATH)


func begin_run() -> void:
	newly_unlocked_this_run.clear()


func has(id: StringName) -> bool:
	return unlocked.has(id)


func try_unlock(id: StringName) -> bool:
	if not DISPLAY_NAMES.has(id):
		return false
	if unlocked.has(id):
		return false
	unlocked[id] = true
	newly_unlocked_this_run.append(id)
	save_to_disk()
	return true


func get_display_name(id: StringName) -> String:
	return DISPLAY_NAMES.get(id, String(id))


func evaluate_after_night(nights_survived: int, cleared_while_down: bool) -> void:
	if nights_survived >= 1:
		try_unlock(NIGHT_1)
	if nights_survived >= 3:
		try_unlock(NIGHT_3)
	if nights_survived >= 5:
		try_unlock(NIGHT_5)
	if cleared_while_down:
		try_unlock(CLEAR_WHILE_DOWN)


func evaluate_day_death() -> void:
	try_unlock(DAY_DEATH)
