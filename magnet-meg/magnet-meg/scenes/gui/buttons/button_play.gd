extends Button

@export var targetSceneUID: StringName

func _on_pressed() -> void:
	get_tree().change_scene_to_file(ResourceUID.path_to_uid(targetSceneUID))


func _on_tree_exiting() -> void:
	globalVar.previousScene = get_tree().current_scene.scene_file_path
	if get_viewport().gui_get_focus_owner() != null:
		if get_viewport().gui_get_focus_owner().name == "PlayButton":
			print("Happy Playing!")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and get_viewport().gui_get_focus_owner() == null:
		grab_focus()
