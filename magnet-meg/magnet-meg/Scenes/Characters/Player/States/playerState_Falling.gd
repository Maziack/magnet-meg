extends PlayerState

@export var coyote_timer: Timer
@export var input_buffer: Timer

func enter(_previous_state_path: String = "", _data: Dictionary = {}) -> void:
	if player.can_jump:
		coyote_timer.wait_time = player.coyote_time
		coyote_timer.start()
	input_buffer.wait_time = player.input_buffer
	$"../../AnimatedSprite2D".set_frame_and_progress(6,0)
	$"../../AnimatedSprite2D".pause()
	print(owner.name," is ", name)
	
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
	$"../../AnimatedSprite2D".set_frame_and_progress(6,0)
	$"../../AnimatedSprite2D".pause()
	
	

			
	if Input.is_action_just_pressed("jump"):
		if player.can_jump:
			coyote_timer.stop()
			finished.emit(JUMPING)
		else: input_buffer.start()
		
	elif direction_x != 0 and (player.wall_detect_left.is_colliding() or player.wall_detect_right.is_colliding()): 
		if (-1 * player.wall_detect_left.get_collision_normal().x) == direction_x or (-1 * player.wall_detect_right.get_collision_normal().x) == direction_x:
			if input_buffer.time_left:
				input_buffer.stop()
				data.queued_action = JUMPING
				finished.emit(WALLPRESSING, data)
				data.clear()
			else:
				finished.emit(WALLPRESSING)
		
	elif player.is_on_floor():
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
			coyote_timer.stop()
			if is_equal_approx(player.velocity.x, 0.0):
				finished.emit(IDLE)
			else:
				finished.emit(RUNNING)
