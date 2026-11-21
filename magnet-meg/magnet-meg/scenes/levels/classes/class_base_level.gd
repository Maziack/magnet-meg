@abstract
class_name BaseLevel
extends Node2D
#Abstract class for all levels

@export var default_spawn : Node2D
enum gateway_enum {}

@onready var main = get_tree().current_scene as Main

#Provides default global position of player in the level
func get_player_spawn() -> Vector2:
	#if main.previous_level
	return default_spawn.get_spawn_position()
