extends PlayerState

func enter(previous_state_path: String = "", data: Dictionary = {}) -> void:
	#player.animation_player.play("normal")
	print(owner.name," is ", name)
	player.is_magnetic = 0

func physics_update(_delta: float) -> void:
	if Input.get_action_strength("mag_trigger") > 0:
		finished.emit(MAGNETIC)
