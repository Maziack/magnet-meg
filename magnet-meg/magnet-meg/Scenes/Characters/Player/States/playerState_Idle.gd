extends PlayerState

func enter(previous_state_path: String = "", data: Dictionary = {}) -> void:
	player.velocity.x = 0.0
	#player.animation_player.play("idle")
	print(owner.name," is ", name)

func physics_update(_delta: float) -> void:
	player.velocity.y += player.gravity * _delta
	#player.move_and_slide()

	if not player.is_on_floor():
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("jump"):
		finished.emit(JUMPING)
	elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		finished.emit(RUNNING)
