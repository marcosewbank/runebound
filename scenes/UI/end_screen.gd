extends CanvasLayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	$%RestartButton.pressed.connect(on_restart_button_pressed)
	$%QuitButton.pressed.connect(on_quit_button_pressed)


func on_restart_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main/base_defense.tscn")


func on_quit_button_pressed():
	get_tree().paused = false
	get_tree().quit()


func set_defeat():
	$%TitleLabel.text = "Defeat"
	$%DescriptionLabel.text = "The Hearth was destroyed."


func set_victory():
	$%TitleLabel.text = "Victory!"
	$%DescriptionLabel.text = "You survived!"
