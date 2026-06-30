extends PlayerState

func enter(_previous_state_path: String = "", _data: Dictionary = {}) -> void:
	if player.can_jump:
		$CoyoteTimer.wait_time = player.coyote_time
		$CoyoteTimer.start()
		#print("Coyote Timer Start")
	$"../../AnimatedSprite2D".set_frame_and_progress(6,0)
	$"../../AnimatedSprite2D".pause()
	#print(owner.name," is ", name)
	
func _on_coyote_timer_timeout() -> void:
	player.can_jump = false
	#print("Coyote Timer Timeout")
	
func physics_update(_delta: float) -> void:
	player.velocity.y += player.gravity * global.delta
	
	var direction_x = int(Input.get_axis("move_left","move_right"))
	var velocity_delta:float = player.air_accel_speed if direction_x != 0 else player.air_decel_speed
	var velocity_target:float = player.top_input_speed if player.top_input_speed > abs(player.velocity.x) else abs(player.velocity.x) - (player.air_decel_speed * global.delta)
	
	player.velocity.x = move_toward(player.velocity.x, velocity_target * direction_x, velocity_delta*global.delta)
	
	
	if direction_x != 0:
		$"../../AnimatedSprite2D".play(animation[str(direction_x)])
	$"../../AnimatedSprite2D".set_frame_and_progress(6,0)
	$"../../AnimatedSprite2D".pause()
	
	if player.is_on_floor():
		$CoyoteTimer.stop()
		if is_equal_approx(player.velocity.x, 0.0):
			finished.emit(IDLE)
		else:
			finished.emit(RUNNING)
	elif player.can_jump and Input.is_action_just_pressed("jump"):
		$CoyoteTimer.stop()
		finished.emit(JUMPING)
