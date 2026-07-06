extends PlayerState

@export var slide_timer: Timer
var slide_timer_finished: bool

func enter(_previous_state_path: String = "", _data: Dictionary = {}) -> void:
	if player.wall_jump_count >= player.wall_jump_max:
		player.can_jump = false
	if _data:
		print("WallPress Enter Queued Action: ", _data.queued_action)
		print("Queued Wall Jump") #Keep input queing from fast falls? Decide after testing as this will negate downward momentum
		finished.emit(_data.queued_action)
	else:
		player.can_jump = true
		slide_timer.wait_time = player.wall_slide_time
		slide_timer_finished = false
	print(owner.name," is ", name)
	
func _on_slide_timer_timeout() -> void:
	slide_timer_finished = true

func physics_update(_delta: float) -> void:
	var direction_x = int(Input.get_axis("move_left","move_right"))
	var wall_press:bool = (player.wall_detect_left.is_colliding() or player.wall_detect_right.is_colliding()) and (((-1 * player.wall_detect_left.get_collision_normal().x) == direction_x) or ((-1 * player.wall_detect_right.get_collision_normal().x) == direction_x))
	var velocity_delta:float = player.air_accel_speed if direction_x != 0 else player.air_decel_speed
	var velocity_target:float = player.top_input_speed if player.top_input_speed > abs(player.velocity.x) else abs(player.velocity.x) - (player.air_decel_speed * global.delta)
	
	player.velocity.x = move_toward(player.velocity.x, velocity_target * direction_x, velocity_delta*global.delta)
	
	if player.velocity.y < 0:
		player.velocity.y += player.gravity * global.delta
	else:
		if slide_timer.is_stopped() and not slide_timer_finished: slide_timer.start()
		player.velocity.y += lerp(player.wall_slide_gravity, player.gravity, (1-(slide_timer.time_left/slide_timer.wait_time))) * global.delta
	
	if direction_x != 0:
		$"../../AnimatedSprite2D".play("move" + animation[str(direction_x)])
	$"../../AnimatedSprite2D".set_frame_and_progress(6,0)
	$"../../AnimatedSprite2D".pause()
	
	
	if player.can_jump and Input.is_action_just_pressed("jump"):
		slide_timer.stop()
		finished.emit(JUMPING)
		
	elif not wall_press:
		if player.is_on_floor():
			slide_timer.stop()
			finished.emit(IDLE)
		else:
			slide_timer.stop()
			finished.emit(FALLING)
