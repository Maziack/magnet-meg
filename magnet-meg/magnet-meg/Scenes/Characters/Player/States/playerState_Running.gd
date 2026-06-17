extends PlayerState

func enter(previous_state_path: String = "", data: Dictionary = {}) -> void:
	#player.animation_player.play("run")
	print(owner.name," is ", name)

func physics_update(delta: float) -> void:
	var direction_x = Input.get_axis("move_left","move_right" )
	var velocity_delta:float = 0
	var velocity_target = 0
	
	velocity_delta = player.run_accel_speed if direction_x != 0 else player.run_decel_speed
	velocity_target = player.top_input_speed
	
	player.velocity.x = move_toward(player.velocity.x, velocity_target * direction_x, velocity_delta)
	#player.move_and_slide()
	
	if not player.is_on_floor():
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("jump"):
		finished.emit(JUMPING)
	elif is_equal_approx(player.velocity.x, 0.0):
		finished.emit(IDLE)
