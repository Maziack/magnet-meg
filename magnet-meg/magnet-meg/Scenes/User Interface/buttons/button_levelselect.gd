extends Button


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/test_level_01.tscn")


func _on_tree_exiting() -> void:
	globalVar.previousScene = get_tree().current_scene.scene_file_path
	if get_viewport().gui_get_focus_owner() != null:
		if get_viewport().gui_get_focus_owner().name == "LevelSelectButton":
			print("Happy Playing!")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and get_viewport().gui_get_focus_owner() == null:
		grab_focus()
