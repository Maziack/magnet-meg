extends Button


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/User Interface/menu_main_options.tscn")

func _on_tree_exiting() -> void:
	globalVar.previousScene = get_tree().current_scene.scene_file_path
