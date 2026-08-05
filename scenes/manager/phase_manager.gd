extends Node
class_name PhaseManager
## Owns day/night phase + run-scoped active door for base defense.

enum Phase { DAY, NIGHT, DAWN }
enum DoorSide { NORTH, EAST, SOUTH, WEST }

signal phase_changed(new_phase: Phase)
signal horn_sounded
signal wave_cleared
signal active_door_chosen(side: DoorSide)

@export var night_stub_seconds: float = 3.0
@export var dawn_stub_seconds: float = 1.5
## When false, Night ends only via clear_wave() (enemy count). Slice 4 disables this.
@export var auto_clear_night: bool = true

var phase: Phase = Phase.DAY
var active_door: DoorSide = DoorSide.NORTH
var nights_survived: int = 0
## Slice 6/7 bookkeeping
var day_deaths: int = 0
var cleared_while_hero_down: bool = false

var _phase_timer: Timer


func _ready() -> void:
	_phase_timer = Timer.new()
	_phase_timer.one_shot = true
	_phase_timer.timeout.connect(_on_phase_timer_timeout)
	add_child(_phase_timer)
	_pick_active_door()
	GameEvents.emit_phase_changed(phase)
	phase_changed.emit(phase)


func _pick_active_door() -> void:
	active_door = [
		DoorSide.NORTH,
		DoorSide.EAST,
		DoorSide.SOUTH,
		DoorSide.WEST,
	].pick_random()
	active_door_chosen.emit(active_door)


func get_phase_name() -> String:
	match phase:
		Phase.DAY:
			return "DAY"
		Phase.NIGHT:
			return "NIGHT"
		Phase.DAWN:
			return "DAWN"
	return "?"


func get_door_name(side: DoorSide = active_door) -> String:
	match side:
		DoorSide.NORTH:
			return "N"
		DoorSide.EAST:
			return "E"
		DoorSide.SOUTH:
			return "S"
		DoorSide.WEST:
			return "W"
	return "?"


## Horn is only meaningful in DAY (including unprepared Night 0).
func sound_horn() -> void:
	if phase != Phase.DAY:
		return
	horn_sounded.emit()
	_set_phase(Phase.NIGHT)
	if auto_clear_night:
		_phase_timer.start(night_stub_seconds)


## Call when night enemies hit 0 (or stub timer if auto_clear_night).
func clear_wave() -> void:
	if phase != Phase.NIGHT:
		return
	_phase_timer.stop()
	nights_survived += 1
	wave_cleared.emit()
	_set_phase(Phase.DAWN)
	_phase_timer.start(dawn_stub_seconds)


func _on_phase_timer_timeout() -> void:
	match phase:
		Phase.NIGHT:
			if auto_clear_night:
				clear_wave()
		Phase.DAWN:
			_set_phase(Phase.DAY)
		_:
			pass


func _set_phase(next: Phase) -> void:
	if phase == next:
		return
	phase = next
	phase_changed.emit(phase)
	GameEvents.emit_phase_changed(phase)
