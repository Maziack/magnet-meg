extends PlayerState

func enter(_previous_state_path: String = "", _data: Dictionary = {}) -> void:
	#player.animation_player.play("magnetic")
	print(owner.name," is ", name)
	player.is_magnetic = 1
	mag_curve_update(0)

func physics_update(_delta: float) -> void:
	var mag_trigger = Input.get_action_strength("mag_trigger")
	
	mag_curve_update(mag_trigger)
	
	if mag_trigger == 0:
		finished.emit(NORMAL)

func mag_curve_update(input) -> void:
	player.reqMagStrength = player.magStrengthCurve.sample(input)
	player.reqOrbitStability = player.magOrbitCurve.sample(input)
