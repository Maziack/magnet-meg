extends CharacterBody2D
class_name Player

@export_subgroup("Player Settings")
@export var mass:float = 60
@export_range(0,2500, 25) var max_velocity:float = 2000 #change this for underwater type magnetic movement?

@export_subgroup("Nodes")
@export var player_input:InputNode
@export var fall_state:StateFall
@export var move_state:StateMove
@export var jump_state:StateJump
@export var magnetic_state:StateMagnetize

var magVelocity:Vector2
###############################################################################
# REDO MAGNETIC PROGRAMMING TO SEPARATE PLAYER VARIABLES VS MAGNET VARIABLES AS WELL AS HANDLE VELOCITY CALCULATIONS BETTER
###############################################################################
func player():
	pass

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	fall_state.handle_gravity(self, delta)
	move_state.handle_horizontal_movement(self, player_input.input_horizontal)
	jump_state.handle_jumping(self, player_input.get_jump_input())
	magnetic_state.handle_magnetization(player_input.get_mag_trigger())
	velocity = velocity.clamp(Vector2(-1*max_velocity,-1*max_velocity),Vector2(max_velocity,max_velocity))
	move_and_slide()
