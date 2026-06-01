@tool
extends Area2D

var px_to_m = 30.48
@export_subgroup("Settings")
@export var collisionShapeCurve:Curve
@export_range(1,10,0.25) var orbitRadius:float:												#in meters	100pix = ~3m
	set(Radius):
		orbitRadius = Radius
		if Engine.is_editor_hint():
			var scaledRadius = Radius*px_to_m
			var fieldOuterRadius = scaledRadius*10
			var fieldInnerRadius = scaledRadius*7.5
			var coreRadius = scaledRadius*0.25
			var coreSpriteScale = collisionShapeCurve.sample(coreRadius)
			if $Orbit/CollisionShape2D:
				$Orbit/CollisionShape2D.shape.radius = scaledRadius
			if $FieldOuter:
				$FieldOuter.shape.radius = fieldOuterRadius
			if $FieldInner:
				$FieldInner/CollisionShape2D.shape.radius = fieldInnerRadius
			if $Core/CollisionShape2D:
				$Core/CollisionShape2D.shape.radius = coreRadius
			if $Core/Sprite2D:
				$Core/Sprite2D.scale = Vector2(coreSpriteScale, coreSpriteScale)
				print("Core Sprite Scale: ", coreSpriteScale)
				print("Core Radius: ", coreRadius)

#var orbitRadius:
	#get:
		#return coreRadius*2	
	#set(value):
			#orbitRadius = value
			#if $Orbit/CollisionShape2D:
				#$Orbit/CollisionShape2D.shape.radius = orbitRadius*px_to_m

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
		coreRadiusPx = orbitRadius*px_to_m
		#coreRadiusPx = coreRadius*px_to_m TRY REMOVING CONVERSION TO PX
		orbitCenter = get_node("OrbitCenter")
		orbit = get_node("Orbit")
		fieldInner = get_node("FieldInner").get_child(0)
		targetPoint = get_node("TargetPoint")
		oldLookAtRotation = orbitCenter.rotation
		var scaledRadius = orbitRadius * px_to_m
		var fieldOuterRadius = scaledRadius*10
		var fieldInnerRadius = scaledRadius*7.5
		var coreRadius = scaledRadius*0.25
		var coreSpriteScale = collisionShapeCurve.sample(coreRadius)
		if $Orbit/CollisionShape2D:
			$Orbit/CollisionShape2D.shape.radius = scaledRadius
		if $FieldOuter:
			$FieldOuter.shape.radius = fieldOuterRadius
		if $FieldInner:
			$FieldInner/CollisionShape2D.shape.radius = fieldInnerRadius
		if $Core/CollisionShape2D:
			$Core/CollisionShape2D.shape.radius = coreRadius
		if $Core/Sprite2D:
			$Core/Sprite2D.scale = Vector2(coreSpriteScale, coreSpriteScale)
			print("Core Sprite Scale: ", coreSpriteScale)
			print("Core Radius: ", coreRadius)

func _physics_process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		var outerBodies = get_overlapping_bodies()
		for body in outerBodies:
			if body is Player and body.magnetic_state.is_magnetic:
				var playerPos = body.get_global_position()
				var playerReqOrbitStability = body.magnetic_state.reqOrbitStability
				var playerReqMagStrength = body.magnetic_state.reqMagStrength
				set_mag_target(playerPos, playerReqOrbitStability)
				add_mag_velocity(body, playerPos, playerReqMagStrength)


func set_mag_target(playerPos,playerReqOrbitStability):
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

func mag_velocity_lo_calc(player, playerPos):
	var magVector = playerPos.direction_to(targetPos)
	var distance = orbitPos.distance_to(playerPos) / px_to_m	#distance in meters
	var magStrength = player.magnetic_state.fluxDensity["Lo"] * (1.33 * 3.14159 * (coreRadiusPx**3)) #field strength x volume of sphere
	var magForce = magStrength / (distance*(0.5*fieldInner.shape.radius/coreRadiusPx))
	#var magForce = magStrength / (distance**2) TRY CHANGING TO THIS ORIGINAL FORMULA
	var magAcceleration = magForce / player.mass
	var magVelocityLo = (magVector * magAcceleration * player.magnetic_state.is_magnetic).clamp(Vector2(-1*player.magnetic_state.maxAcceleration["Lo"],-1*player.magnetic_state.maxAcceleration["Lo"]),Vector2(player.magnetic_state.maxAcceleration["Lo"],player.magnetic_state.maxAcceleration["Lo"]))
	### var orbitStability = Vector2.ZERO						### Future experiment: When traveling 
	### newDistance = playerPos.distance_to(orbitPos)			### past orbitCenter reduce forward 
	### if distance > (oldDistance / px_to_m):					### velocity and nudge into either CW  
	###		orbitStability = playerPos.direction_to(orbitPos)	### or CCW orbit direction, similar to
	###															### apogee/perigee orbit stabilization
	return magVelocityLo

func mag_velocity_hi_calc(player, playerPos):
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

func add_mag_velocity(player, playerPos, playerReqMagStrength):
	var magVelocityFinal
	magVelocityFinal = mag_velocity_lo_calc(player,playerPos).lerp(mag_velocity_hi_calc(player,playerPos),playerReqMagStrength)
	oldLookAtRotation = orbitCenter.rotation
	player.velocity += magVelocityFinal
