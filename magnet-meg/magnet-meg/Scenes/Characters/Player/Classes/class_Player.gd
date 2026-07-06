extends CharacterBody2D
class_name Player

@export_subgroup("Physics and Timing")
@export var mass:float = 60 #kg
@export var gravity:float = 18 #?
@export var wall_slide_gravity:float = 2 #?
@export var wall_slide_time:float = 1.5 #sec
@export var wall_jump_max:int = 3
@export var wall_detect_left: RayCast2D
@export var wall_detect_right: RayCast2D
@export var coyote_time:float = 0.12 #sec
@export var input_buffer:float = 0.18 #sec


@export_subgroup("Velocity Settings")
@export var jump_velocity:float = -400 #px
@export var wall_jump_pushback:float = 400 #px
@export var run_accel_speed:float = 80 #px
@export var run_decel_speed:float = 40 #px
@export var air_accel_speed:float = 16 #px
@export var air_decel_speed:float = 2 #px
@export var top_input_speed:float = 500 #px
@export_range(0,2500, 25) var max_velocity:float = 2000 #px #change this for underwater type magnetic movement?

@export_subgroup("Magnet Settings")
@export_range(0.01, 0.1, 0.01) var fluxDensityLo:float = 0.02 # In Tesla
@export_range(50, 200, 25) var maxAccelerationLo:float = 150
@export_range(0.5, 10, 0.5) var fluxDensityHi:float = 5.0 # In Tesla
@export_range(200, 500, 25) var maxAccelerationHi:float = 250 #px
@export var magStrengthCurve: Curve
@export var magOrbitCurve: Curve

var can_jump:bool = true
var wall_jump_count = 0
var is_magnetic:float
var reqMagStrength:float
var reqOrbitStability:float
var fluxDensity:Dictionary = {"Lo":fluxDensityLo, "Hi":fluxDensityHi}
var maxAcceleration:Dictionary = {"Lo":maxAccelerationLo, "Hi":maxAccelerationHi}


#var magVelocity:Vector2

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	
	velocity = (velocity).clamp(Vector2(-1*max_velocity,-1*max_velocity),Vector2(max_velocity,max_velocity))
	move_and_slide()
