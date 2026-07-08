extends PlayerState

@export var coyote_timer: Timer
@export var input_buffer: Timer

func enter(previous_state_path: String = "", _data: Dictionary = {}) -> void:
	print(owner.name," is ", name)
	if previous_state_path == RUNNING:
		player.can_jump = true
		coyote_timer.wait_time = player.coyote_time
		coyote_timer.start()
	else: player.can_jump = false
	input_buffer.wait_time = player.input_buffer
	$"../../AnimatedSprite2D".set_frame_and_progress(6,0)
	$"../../AnimatedSprite2D".pause()
	
func _on_coyote_timer_timeout() -> void:
	player.can_jump = false
	
func physics_update(_delta: float) -> void:
	player.velocity.y += player.gravity * global.delta
	
	var direction_x = 0
	direction_x = int(Input.get_axis("move_left","move_right"))
	var velocity_delta:float = player.air_accel_speed if direction_x != 0 else player.air_decel_speed
	var velocity_target:float = player.top_input_speed if player.top_input_speed > abs(player.velocity.x) else abs(player.velocity.x) - (player.air_decel_speed * global.delta)
	
	player.velocity.x = move_toward(player.velocity.x, velocity_target * direction_x, velocity_delta*global.delta)
	
	
	if direction_x != 0:
		$"../../AnimatedSprite2D".play("move" + animation[str(sign(int(direction_x)))])
	elif player.velocity.x > 0:
		$"../../AnimatedSprite2D".play("move_right")
	elif player.velocity.x < 0:
		$"../../AnimatedSprite2D".play("move_left")
	$"../../AnimatedSprite2D".set_frame_and_progress(6,0)
	$"../../AnimatedSprite2D".pause()
	
	

			
	if Input.is_action_just_pressed("jump"):
		if player.can_jump:
			coyote_timer.stop()
			finished.emit(JUMPING)
		else: input_buffer.start()
		
	elif ((player.wall_jump_count > 0) or (direction_x != 0)) and (player.wall_detect_left.is_colliding() or player.wall_detect_right.is_colliding()): 
			if not input_buffer.is_stopped():
				input_buffer.stop()
				data.queued_action = JUMPING
				#print("Fall State Exit to Wall Jump")
				finished.emit(WALLPRESSING, data)
				data.clear()
			else:
				#print("Fall State Exit to Wall Press")
				finished.emit(WALLPRESSING)
		
	elif player.is_on_floor():
		if not input_buffer.is_stopped():
			input_buffer.stop()
			data.queued_action = JUMPING
			if is_equal_approx(player.velocity.x, 0.0):
				finished.emit(IDLE, data)
				data.clear()
			else:
				finished.emit(RUNNING, data)
				data.clear()
		else:
			coyote_timer.stop()
			if is_equal_approx(player.velocity.x, 0.0):
				finished.emit(IDLE)
			else:
				finished.emit(RUNNING)
