class_name Gateway
extends Area2D

@onready var main = get_tree().current_scene as Main

@export var target_level: Main.level_enum

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		print("Gateway _on_body_entered target_level: ", target_level)
		main._load_level_enum(target_level)
		
