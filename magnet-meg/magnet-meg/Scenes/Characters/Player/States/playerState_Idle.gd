extends PlayerState

func enter(_previous_state_path: String = "", _data: Dictionary = {}) -> void:
	player.velocity.x = 0.0
	$"../../AnimatedSprite2D".stop()
	#print(owner.name," is ", name)

func physics_update(delta: float) -> void:
	player.velocity.y += player.gravity * delta

	if not player.is_on_floor():
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("jump"):
		finished.emit(JUMPING)
	elif Input.is_action_pressed("move_left"):
		data.animation = "move_left"
		finished.emit(RUNNING,data)
		data.clear()
	elif Input.is_action_pressed("move_right"):
		data.animation = "move_right"
		finished.emit(RUNNING,data)
		data.clear()
