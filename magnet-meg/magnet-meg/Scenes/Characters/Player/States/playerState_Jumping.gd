extends PlayerState

func enter(previous_state_path: String = "", data: Dictionary = {}) -> void:
	player.velocity.y = player.jump_velocity
	#player.animation_player.play("jump")
	print(owner.name," is ", name)

func physics_update(_delta: float) -> void:
	player.velocity.y += player.gravity * _delta
	
	var direction_x = Input.get_axis("move_left","move_right" )
	var velocity_delta:float = 0
	var velocity_target = 0
	
	velocity_delta = player.air_accel_speed if direction_x != 0 else player.air_decel_speed
	velocity_target = player.top_input_speed
	
	player.velocity.x = move_toward(player.velocity.x, velocity_target * direction_x, velocity_delta)
	#player.move_and_slide()
	
	if player.velocity.y >= 0:
		finished.emit(FALLING)
