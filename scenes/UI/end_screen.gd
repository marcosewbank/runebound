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


func show_run_summary(nights_survived: int, newly_unlocked: Array) -> void:
	var lines: PackedStringArray = []
	lines.append("Nights survived: %d" % nights_survived)
	if newly_unlocked.is_empty():
		lines.append("No new achievements.")
	else:
		lines.append("New achievements:")
		for id in newly_unlocked:
			lines.append("• %s" % AchievementStore.get_display_name(id))
	$%DescriptionLabel.text = "\n".join(lines)
	_ensure_achievements_label(newly_unlocked)


func _ensure_achievements_label(newly_unlocked: Array) -> void:
	var box := $MarginContainer/PanelContainer/MarginContainer/VBoxContainer
	var existing := box.get_node_or_null("AchievementsLabel") as Label
	if existing == null:
		existing = Label.new()
		existing.name = "AchievementsLabel"
		existing.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		existing.add_theme_font_size_override("font_size", 11)
		box.add_child(existing)
		box.move_child(existing, 2)  # before buttons
	if newly_unlocked.is_empty():
		existing.text = ""
		existing.visible = false
	else:
		existing.visible = true
		var names: PackedStringArray = []
		for id in newly_unlocked:
			names.append(AchievementStore.get_display_name(id))
		existing.text = "Unlocked:\n" + "\n".join(names)
