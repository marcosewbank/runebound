extends Node

signal experience_collected(experience_amount: float)
signal ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary)
signal phase_changed(new_phase: int)


func emit_experience_collected(experience_amount: float):
	experience_collected.emit(experience_amount)


func emit_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	ability_upgrade_added.emit(upgrade, current_upgrades)


func emit_phase_changed(new_phase: int) -> void:
	phase_changed.emit(new_phase)
