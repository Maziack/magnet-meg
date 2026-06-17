class_name StateJump
extends Node

@export_subgroup("Settings")
@export var jump_velocity:float = -400

var is_jumping:bool = false

func handle_jumping(body:CharacterBody2D, jump_input):
	if jump_input and body.is_on_floor():
		body.velocity.y = jump_velocity
