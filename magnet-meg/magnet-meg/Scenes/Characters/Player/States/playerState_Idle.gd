extends PlayerState

func enter(_previous_state_path: String = "", _data: Dictionary = {}) -> void:
	if _data:
		finished.emit(_data.queued_action)
	else:
		player.velocity.x = 0.0
		player.can_jump = true
		$"../../AnimatedSprite2D".stop()
	print(owner.name," is ", name)

func physics_update(_delta: float) -> void:
	player.velocity.y += player.gravity * global.delta

	if not player.is_on_floor():
		finished.emit(FALLING)
	elif player.can_jump and Input.is_action_just_pressed("jump"):
		finished.emit(JUMPING)
	elif Input.is_action_pressed("move_left"):
		finished.emit(RUNNING)
	elif Input.is_action_pressed("move_right"):
		finished.emit(RUNNING)
