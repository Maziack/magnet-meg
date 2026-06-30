extends CharacterBody2D
class_name Player

@export_subgroup("Physics Properties")
@export var mass:float = 60
@export var gravity:float = 18
@export var coyote_time:float = 0.2

@export_subgroup("Velocity Settings")
@export var jump_velocity:float = -400
@export var run_accel_speed:float = 60
@export var run_decel_speed:float = 40
@export var air_accel_speed:float = 20
@export var air_decel_speed:float = 2
@export var top_input_speed:float = 500
@export_range(0,2500, 25) var max_velocity:float = 2000 #change this for underwater type magnetic movement?

@export_subgroup("Magnet Settings")
@export_range(0.01, 0.1, 0.01) var fluxDensityLo:float = 0.02 # In Tesla
@export_range(50, 200, 25) var maxAccelerationLo:float = 150
@export_range(0.5, 10, 0.5) var fluxDensityHi:float = 5.0 # In Tesla
@export_range(200, 500, 25) var maxAccelerationHi:float = 250
@export var magStrengthCurve: Curve
@export var magOrbitCurve: Curve

var can_jump:bool = true
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
