extends Node
class_name PlayerInventory

signal changed

var wood: int = 0
var stone: int = 0
var scrap: int = 0


func _ready() -> void:
	add_to_group(Groups.PLAYER_INVENTORY)


func add_wood(amount: int) -> void:
	wood += amount
	changed.emit()


func add_stone(amount: int) -> void:
	stone += amount
	changed.emit()


func add_scrap(amount: int) -> void:
	scrap += amount
	changed.emit()


func try_spend_wood(amount: int) -> bool:
	if wood < amount:
		return false
	wood -= amount
	changed.emit()
	return true


func try_spend_stone(amount: int) -> bool:
	if stone < amount:
		return false
	stone -= amount
	changed.emit()
	return true
