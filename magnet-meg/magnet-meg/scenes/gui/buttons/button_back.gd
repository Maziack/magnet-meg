extends Button


func _on_pressed() -> void:
	get_tree().change_scene_to_file(globalVar.previousScene)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and get_viewport().gui_get_focus_owner() == null:
		grab_focus()
