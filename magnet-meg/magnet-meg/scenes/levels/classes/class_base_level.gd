@abstract
class_name BaseLevel
extends Node2D
#Abstract class for all levels

@export var player_spawn : SpawnPoint

#Provides default global position of player in the level
@abstract func get_player_spawn() -> Vector2
