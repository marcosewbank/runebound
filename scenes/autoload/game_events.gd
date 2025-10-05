extends Node

signal experience_collected(experience_amount:float)
signal ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary)

func emit_experience_collected(experience_amount: float):
	experience_collected.emit(experience_amount)
	

func emit_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	ability_upgrade_added.emit(upgrade, current_upgrades)
