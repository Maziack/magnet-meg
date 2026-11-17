extends BaseMenu

func _on_play_button_pressed() -> void:
	load_level(main.TEST_LEVEL_01)


func _on_options_button_pressed() -> void:
	load_menu(main.MENU_MAIN_OPTIONS_UID)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
