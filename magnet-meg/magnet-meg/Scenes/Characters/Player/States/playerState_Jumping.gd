extends PlayerState

@export var input_buffer: Timer

func enter(_previous_state_path: String = "", _data: Dictionary = {}) -> void:
	if _previous_state_path == WALLPRESSING:
		player.velocity.y = player.jump_velocity * 1.2
		player.velocity.x = player.wall_jump_pushback * player.get_wall_normal().x
		$"../../AnimatedSprite2D".play("move" + animation[str(sign(int(player.velocity.x)))])
		$"../../AnimatedSprite2D".set_frame_and_progress(7,0)
		$"../../AnimatedSprite2D".pause()
	else: 
		player.velocity.y = player.jump_velocity
		$"../../AnimatedSprite2D".set_frame_and_progress(7,0)
		$"../../AnimatedSprite2D".pause()
	player.can_jump = false
	input_buffer.wait_time = player.input_buffer

	print(owner.name," is ", name)

func physics_update(_delta: float) -> void:
	player.velocity.y += player.gravity * global.delta
	
	var direction_x = int(Input.get_axis("move_left","move_right"))
	var velocity_delta:float = player.air_accel_speed if direction_x != 0 else player.air_decel_speed
	var velocity_target:float = player.top_input_speed if player.top_input_speed > abs(player.velocity.x) else abs(player.velocity.x) - (player.air_decel_speed * global.delta)
	
	player.velocity.x = move_toward(player.velocity.x, velocity_target * direction_x, velocity_delta*global.delta)
	
	
	if player.velocity.x != 0:
		$"../../AnimatedSprite2D".play("move" + animation[str(sign(int(player.velocity.x)))])
	$"../../AnimatedSprite2D".set_frame_and_progress(7,0)
	$"../../AnimatedSprite2D".pause()
	
	if not player.can_jump and Input.is_action_just_pressed("jump"):
		input_buffer.start()
	
	elif player.velocity.y >= 0:
		finished.emit(FALLING)
	
	if player.is_on_wall() and (-1 * player.get_wall_normal().x) == direction_x:
		if input_buffer.time_left:
			input_buffer.stop()
			data.queued_action = JUMPING
			finished.emit(WALLPRESSING, data)
			data.clear()
		else:
			finished.emit(WALLPRESSING)
