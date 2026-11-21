class_name Gateway
extends Area2D

@export var target_level : Main.level_enum
@export var player_spawn : Node2D

@onready var main = get_tree().current_scene as Main

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		print("Gateway;  _on_body_entered target_level: ", target_level)
		print("Gateway; This should say Main: ", main.name)
		main._load_level_enum(target_level)

#Provides default global position of player in the level
func get_spawn_position() -> Vector2:
	return player_spawn.get_spawn_position()
