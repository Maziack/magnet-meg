class_name State
extends Node

var data: Dictionary = {}

signal finished(next_state_path: String, data: Dictionary)

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func enter(_previous_state_path: String = "", _data: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass
