extends PlayerState

@export var slide_timer: Timer
var slide_timer_finished: bool

func enter(_previous_state_path: String = "", _data: Dictionary = {}) -> void:
	print(owner.name," is ", name, " after ", _previous_state_path)
	
	if (player.wall_jump_max != 0) and (player.wall_jump_count >= player.wall_jump_max):
		player.can_jump = false
	elif _data:
		#print("WallPress State Enter: Queued Wall Jump")
		finished.emit(_data.queued_action)	#Keep input queing from fast falls? Decide after testing as this will negate downward momentum
	else:
		player.can_jump = true
		#print("WallPress State Enter: Wall Press and Can Jump")
		slide_timer.wait_time = player.wall_slide_time
		slide_timer_finished = false
	
	
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
		#print("WallPress State Exit to Jump")
		finished.emit(JUMPING)
		
	elif player.is_on_floor():
		slide_timer.stop()
		player.can_jump = true
		if not wall_press:
			finished.emit(IDLE)
	elif not wall_press:
		slide_timer.stop()
		#print("WallPress State Exit to Fall")
		finished.emit(FALLING)
