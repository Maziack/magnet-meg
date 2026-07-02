extends PlayerState

@export var slide_timer: Timer
var slide_timer_finished: bool

func enter(_previous_state_path: String = "", _data: Dictionary = {}) -> void:
	if _data:
		finished.emit(_data.queued_action)
		print("Queued Wall Jump") #Keep input queing from fast falls? Decide after testing as this will negate downward momentum
	else:
		player.can_jump = true
		slide_timer.wait_time = player.wall_slide_time
		slide_timer_finished = false
	print(owner.name," is ", name)
	
func _on_slide_timer_timeout() -> void:
	slide_timer_finished = true

func physics_update(_delta: float) -> void:
	var direction_x = int(Input.get_axis("move_left","move_right"))
	var wall_press = -1 * player.get_wall_normal().x == direction_x
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
		
	elif player.is_on_floor() and not wall_press:
		slide_timer.stop()
		finished.emit(IDLE)
		
	elif player.is_on_floor() and not player.is_on_wall():
		slide_timer.stop()
		finished.emit(RUNNING)
			
	elif not player.is_on_floor() and not player.is_on_wall() and (direction_x == 0 or player.velocity.x !=0):
		slide_timer.stop()
		finished.emit(FALLING)
