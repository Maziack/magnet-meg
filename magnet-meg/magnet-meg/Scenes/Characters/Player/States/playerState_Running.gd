extends PlayerState

func enter(_previous_state_path: String = "", _data: Dictionary = {}) -> void:
	player.wall_jump_count = 0
	print("Wall Jump Combo Reset: ", self.name)
	if _data:
		finished.emit(_data.queued_action)
	else:
		player.can_jump = true
	print(owner.name," is ", name)

func physics_update(_delta: float) -> void:
	var direction_x := int(Input.get_axis("move_left","move_right"))
	var velocity_delta:float = player.run_accel_speed if direction_x != 0 else player.run_decel_speed
	var velocity_target:float = player.top_input_speed if player.top_input_speed > abs(player.velocity.x) else abs(player.velocity.x) - (0.4 * player.run_decel_speed * global.delta)
	
	player.velocity.x = move_toward(player.velocity.x, velocity_target * direction_x, velocity_delta*global.delta)
	
	if direction_x != 0:
		$"../../AnimatedSprite2D".play("move" + animation[str(direction_x)])
	else: $"../../AnimatedSprite2D".stop()
	
	if player.wall_detect_left.is_colliding() or player.wall_detect_right.is_colliding(): 
		if (-1 * player.wall_detect_left.get_collision_normal().x) == direction_x or (-1 * player.wall_detect_right.get_collision_normal().x) == direction_x:
			finished.emit(WALLPRESSING)
	elif not player.is_on_floor(): finished.emit(FALLING)
	elif player.can_jump and Input.is_action_just_pressed("jump"): finished.emit(JUMPING)
	elif is_equal_approx(player.velocity.x, 0.0): finished.emit(IDLE)
