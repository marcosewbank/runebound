extends CanvasLayer
class_name BuildMenu
## Toggle with B. Select a building, then place with E while Day ghost is valid.

signal building_selected(def: BuildingDef)
signal closed

@export var catalog: Array[BuildingDef] = []

@onready var panel: PanelContainer = $Panel
@onready var list: VBoxContainer = $Panel/Margin/VBox/List
@onready var hint: Label = $Panel/Margin/VBox/Hint

var selected: BuildingDef
var _open: bool = false


func _ready() -> void:
	if catalog.is_empty():
		catalog = [
			load("res://resources/buildings/wooden_wall.tres") as BuildingDef,
			load("res://resources/buildings/weapon_stand.tres") as BuildingDef,
		]
	visible = false
	_rebuild_list()
	_set_open(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("build_menu"):
		_set_open(not _open)
		get_viewport().set_input_as_handled()


func is_open() -> bool:
	return _open


func get_selected() -> BuildingDef:
	return selected


func _set_open(open: bool) -> void:
	_open = open
	visible = open
	panel.visible = open
	if open:
		_rebuild_list()
	else:
		closed.emit()


func _rebuild_list() -> void:
	for child in list.get_children():
		child.queue_free()
	for def in catalog:
		if def == null:
			continue
		var btn := Button.new()
		btn.text = "%s  (%dW %dS)" % [def.display_name, def.wood_cost, def.stone_cost]
		btn.tooltip_text = def.description
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_building_pressed.bind(def))
		list.add_child(btn)
		if selected == null:
			_select(def)
	if selected != null:
		hint.text = "Selected: %s — Day only, E to place" % selected.display_name


func _on_building_pressed(def: BuildingDef) -> void:
	_select(def)


func _select(def: BuildingDef) -> void:
	selected = def
	hint.text = "Selected: %s — Day only, E to place" % def.display_name
	building_selected.emit(def)
	# Highlight
	for child in list.get_children():
		if child is Button:
			child.modulate = Color(1, 1, 1, 1)
	# last pressed approx — set selected button modulate
	for child in list.get_children():
		if child is Button and def.display_name in child.text:
			child.modulate = Color(0.7, 1.0, 0.75, 1.0)
			break
