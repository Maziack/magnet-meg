class_name StateMagnetize
extends Node

@export_subgroup("Settings")
@export_range(0.01, 0.1, 0.01) var fluxDensityLo:float = 0.02
@export_range(50, 200, 25) var maxAccelerationLo:float = 150
@export_range(0.5, 10, 0.5) var fluxDensityHi:float = 5.0
@export_range(200, 500, 25) var maxAccelerationHi:float = 250
@export var magStrengthCurve: Curve
@export var magOrbitCurve: Curve

var is_magnetic = 0
var reqMagStrength
var reqOrbitStability
var fluxDensity = {"Lo":fluxDensityLo, "Hi":fluxDensityHi}
var maxAcceleration = {"Lo":maxAccelerationLo, "Hi":maxAccelerationHi}

func handle_magnetization(mag_trigger):
	if mag_trigger > 0:
		is_magnetic = 1
	else:
		is_magnetic = 0
	
	reqMagStrength = magStrengthCurve.sample(mag_trigger)
	reqOrbitStability = magOrbitCurve.sample(mag_trigger)
