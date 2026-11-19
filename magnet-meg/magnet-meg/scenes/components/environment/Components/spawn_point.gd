class_name SpawnPoint
extends Node2D

@export var raycast : RayCast2D

## Entity spawn position (Vector2).
var spawn_position  : Vector2

func get_spawn_position() -> Vector2:
	spawn_position = raycast.target_position
	return spawn_position
