extends PlayerState

func enter(_previous_state_path: String = "", _data: Dictionary = {}) -> void:
	if _data:
		finished.emit(_data.queued_action)
	else:
		player.can_jump = true
	print(owner.name," is ", name)
	
func physics_update(_delta: float) -> void:
	var direction_x = int(Input.get_axis("move_left","move_right"))
	var velocity_delta:float = player.air_accel_speed if direction_x != 0 else player.air_decel_speed
	var velocity_target:float = player.top_input_speed if player.top_input_speed > abs(player.velocity.x) else abs(player.velocity.x) - (player.air_decel_speed * global.delta)
	
	player.velocity.y += move_toward(player.velocity.y, )player.gravity * global.delta
	
	player.velocity.x = move_toward(player.velocity.x, velocity_target * direction_x, velocity_delta*global.delta)
	
	
	if direction_x != 0:
		$"../../AnimatedSprite2D".play(animation[str(direction_x)])
	$"../../AnimatedSprite2D".set_frame_and_progress(6,0)
	$"../../AnimatedSprite2D".pause()
	
	
			
	if player.can_jump and Input.is_action_just_pressed("jump"):
		finished.emit(JUMPING)
		
	elif player.is_on_floor() and direction_x == 0:
		if input_buffer.time_left:
			input_buffer.stop()
			data.queued_action = JUMPING
			if is_equal_approx(player.velocity.x, 0.0):
				finished.emit(IDLE, data)
				data.clear()
			else:
				finished.emit(RUNNING, data)
				data.clear()
		else:
			if is_equal_approx(player.velocity.x, 0.0):
				finished.emit(IDLE)
			else:
				finished.emit(RUNNING)
