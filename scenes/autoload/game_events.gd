extends Node

signal experience_collected(experience_amount:float)

func emit_experience_collected(experience_amount: float):
	experience_collected.emit(experience_amount)
	
