extends Player

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	#print("Y Velocity: ", velocity.y)
	velocity = (velocity).clamp(Vector2(-1*max_velocity,-1*max_velocity),Vector2(max_velocity,max_velocity))
	move_and_slide()
