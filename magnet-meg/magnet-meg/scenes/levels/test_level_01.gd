class_name TestLevel01
extends BaseLevel

@export var player : Player

func get_player_spawn() -> Vector2:
	return player_spawn.get_spawn_position()
