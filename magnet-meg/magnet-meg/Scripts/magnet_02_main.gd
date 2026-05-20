@tool
extends Area2D

var px_to_m = 30.48
@export_subgroup("Settings")
@export var collisionShapeCurve:Curve
@export_range(1,10,0.25) var coreRadius:float:												#in meters	100pix = ~3m
	set(orbitRadius):
		coreRadius = orbitRadius
		var spriteScale
		if $Orbit/CollisionShape2D:
			$Orbit/CollisionShape2D.shape.radius = orbitRadius*px_to_m
		if $FieldOuter:
			$FieldOuter.shape.radius = orbitRadius*px_to_m*10
		if $FieldInner:
			$FieldInner/CollisionShape2D.shape.radius = $FieldOuter.shape.radius*0.75
		if $Core/CollisionShape2D:
			$Core/CollisionShape2D.shape.radius = orbitRadius*px_to_m*0.25
			spriteScale = collisionShapeCurve.sample($Core/CollisionShape2D.shape.radius)
		if $Core/Sprite2D:
			$Core/Sprite2D.scale = Vector2(spriteScale, spriteScale)

#var orbitRadius:
	#get:
		#return coreRadius*2	
	#set(value):
			#orbitRadius = value
			#if $Orbit/CollisionShape2D:
				#$Orbit/CollisionShape2D.shape.radius = orbitRadius*px_to_m
var player
var playerPos
var playerReqOrbitStability
var playerReqMagStrength

var orbitPos
var orbitCenter
var orbit
var fieldInner
var approachAngle
var targetVector:Vector2
var targetPos
var oldLookAtRotation
var newLookAtRotation
var oldDistance
var newDistance
var targetPoint
var coreRadiusPx



####################################################################################################

func _ready() -> void:
	if not Engine.is_editor_hint():
		player = %Player
		coreRadiusPx = coreRadius*px_to_m
		orbitCenter = get_node("OrbitCenter")
		orbit = get_node("Orbit")
		fieldInner = get_node("FieldInner").get_child(0)
		targetPoint = get_node("TargetPoint")
		oldLookAtRotation = orbitCenter.rotation

func _physics_process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		var outerBodies = get_overlapping_bodies()
		for body in outerBodies:
			if body.name == "Player" and player.magnetic_state.is_magnetic:
				playerReqMagStrength = player.magnetic_state.reqMagStrength
				playerReqOrbitStability = player.magnetic_state.reqOrbitStability
				set_mag_target()
				add_mag_velocity()


func set_mag_target():
	playerPos = player.get_global_position()
	orbitCenter.look_at(playerPos)
	orbitPos = orbitCenter.get_global_position()
	approachAngle = (playerPos-orbitPos).angle()
	newLookAtRotation = orbitCenter.rotation
	if newLookAtRotation > oldLookAtRotation:
		targetVector = Vector2.DOWN.rotated(approachAngle)	#CW
	elif newLookAtRotation < oldLookAtRotation:
		targetVector = Vector2.UP.rotated(approachAngle)	#CCW
	targetPos = orbitPos+(playerReqOrbitStability * targetVector * orbit.get_node("CollisionShape2D").shape.radius) # // coefficient of 0 for weak, 1 for strong
	targetPoint.set_global_position(targetPos)

func mag_velocity_lo_calc():
	var magVector = playerPos.direction_to(targetPos)
	var distance = orbitPos.distance_to(playerPos) / px_to_m	#distance in meters
	var magStrength = player.magnetic_state.fluxDensity["Lo"] * (1.33 * 3.14159 * (coreRadiusPx**3)) #field strength x volume of sphere
	var magForce = magStrength / (distance*(0.5*fieldInner.shape.radius/coreRadiusPx))
	var magAcceleration = magForce / player.mass
	var magVelocityLo = (magVector * magAcceleration * player.magnetic_state.is_magnetic).clamp(Vector2(-1*player.magnetic_state.maxAcceleration["Lo"],-1*player.magnetic_state.maxAcceleration["Lo"]),Vector2(player.magnetic_state.maxAcceleration["Lo"],player.magnetic_state.maxAcceleration["Lo"]))
	### var orbitStability = Vector2.ZERO						### Future experiment: When traveling 
	### newDistance = playerPos.distance_to(orbitPos)			### past orbitCenter reduce forward 
	### if distance > (oldDistance / px_to_m):					### velocity and nudge into either CW  
	###		orbitStability = playerPos.direction_to(orbitPos)	### or CCW orbit direction, similar to
	###															### apogee/perigee orbit stabilization
	return magVelocityLo

func mag_velocity_hi_calc():
	var magVector = playerPos.direction_to(targetPos)
	var distance = orbitPos.distance_to(playerPos) / px_to_m	#distance in meters
	var magStrength = player.magnetic_state.fluxDensity["Hi"] * (1.33 * 3.14159 * (coreRadiusPx**3)) #field strength x volume of sphere
	var magForce = magStrength / (distance*(0.5*fieldInner.shape.radius/coreRadiusPx))
	var magAcceleration = magForce / player.mass
	var magVelocityHi = (magVector * magAcceleration * player.magnetic_state.is_magnetic).clamp(Vector2(-1*player.magnetic_state.maxAcceleration["Hi"],-1*player.magnetic_state.maxAcceleration["Hi"]),Vector2(player.magnetic_state.maxAcceleration["Hi"],player.magnetic_state.maxAcceleration["Hi"]))
	### var orbitStability = Vector2.ZERO						### Future experiment: When traveling 
	### newDistance = playerPos.distance_to(orbitPos)			### past orbitCenter reduce forward 
	### if distance > (oldDistance / px_to_m):					### velocity and nudge into either CW  
	###		orbitStability = playerPos.direction_to(orbitPos)	### or CCW orbit direction, similar to
	###															### apogee/perigee orbit stabilization
	return magVelocityHi

func add_mag_velocity():
	var magVelocityFinal
	magVelocityFinal = mag_velocity_lo_calc().lerp(mag_velocity_hi_calc(),playerReqMagStrength)
	oldLookAtRotation = orbitCenter.rotation
	player.velocity += magVelocityFinal
