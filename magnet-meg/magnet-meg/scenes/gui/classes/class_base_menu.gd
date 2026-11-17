@abstract
class_name BaseMenu
extends Control
#Abstract class for all menus

@onready var main = get_tree().current_scene as Main

@export var default_focus : Button

signal load_menu_signal(scene_uid)
signal load_level_signal(scene_uid)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and get_viewport().gui_get_focus_owner() == null:
		default_focus.grab_focus()

func load_menu(scene_uid) -> void:
	load_menu_signal.emit(scene_uid)

func load_level(scene_uid) -> void:
	load_level_signal.emit(scene_uid)
