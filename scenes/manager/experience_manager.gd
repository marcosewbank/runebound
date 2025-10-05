extends Node

signal experience_updated(current_experience: float, target_experience: float)
signal level_up(new_level: int)

const TARGET_EXPERIENCE_GROWTH = 5
@export var current_experience = 0
@export var current_level = 1
@export var target_experience = 5

func _ready():
	GameEvents.experience_collected.connect(on_experience_collected)
	
func increment_experinece(experience_amount: float):
	
	print("current_level", current_level)
	
	current_experience = min(current_experience + experience_amount, target_experience)
	experience_updated.emit(current_experience, target_experience)
	
	if current_experience == target_experience:
		current_level += 1
		target_experience += TARGET_EXPERIENCE_GROWTH
		current_experience = 0
		experience_updated.emit(current_experience, target_experience)
		level_up.emit(current_level)

func on_experience_collected(experience_amount: float):
	increment_experinece(experience_amount)
