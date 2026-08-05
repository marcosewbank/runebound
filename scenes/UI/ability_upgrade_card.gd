extends PanelContainer

signal selected_upgrade

@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel

func _ready():
	gui_input.connect(on_gui_input)
	
func set_ability_upgrade(upgrade: AbilityUpgrade):
	name_label.text = upgrade.name
	description_label.text = upgrade.description

func on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		selected_upgrade.emit()
