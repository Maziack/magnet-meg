class_name InputNode
extends Node

var input_horizontal:float = 0

func _process(_delta: float) -> void:
	input_horizontal = Input.get_axis("move_left", "move_right")
	
func get_jump_input():
	return Input.is_action_just_pressed("jump")

func get_jump_release():
	return Input.is_action_just_released("jump")

func get_mag_trigger():
	return Input.get_action_strength("mag_trigger")
