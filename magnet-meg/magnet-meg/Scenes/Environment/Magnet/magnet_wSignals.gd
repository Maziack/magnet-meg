@tool
extends Node2D

@export_subgroup("Settings")
@export var collisionShapeCurve:Curve
@export_range(1,10,0.1) var orbitRadius:float:						#in meters	100pix = ~3m
	set(Radius):
		orbitRadius = Radius
		var scaledRadius = Radius*global.px_to_m
		var fieldOuterRadius = scaledRadius*10
		var fieldInnerRadius = scaledRadius*7.5
		var coreRadius = scaledRadius*0.25
		#print(coreRadius)
		var coreSpriteScale = collisionShapeCurve.sample(coreRadius)
		if self.has_node(^"Orbit"):
			self.get_node(^"Orbit/CollisionShape2D").shape.radius = scaledRadius
		if self.has_node(^"FieldOuter"):
			self.get_node(^"FieldOuter/CollisionShape2D").shape.radius = fieldOuterRadius
		if self.has_node(^"FieldInner"):
			self.get_node(^"FieldInner/CollisionShape2D").shape.radius = fieldInnerRadius
		if self.has_node(^"Core"):
			self.get_node(^"Core/CollisionShape2D").shape.radius = coreRadius
			self.get_node(^"Core/Sprite2D").scale = Vector2(coreSpriteScale, coreSpriteScale)

var orbitPos
var orbitCenter
var orbit
var fieldOuter
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
		coreRadiusPx = orbitRadius*global.px_to_m
		#coreRadiusPx = coreRadius*global.px_to_m TRY REMOVING CONVERSION TO PX
		orbitCenter = get_node("OrbitCenter")
		orbit = get_node("Orbit")
		fieldOuter = get_node("FieldOuter")
		fieldInner = get_node("FieldInner").get_child(0)
		targetPoint = get_node("TargetPoint")
		oldLookAtRotation = orbitCenter.rotation

func _physics_process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		var outerBodies = fieldOuter.get_overlapping_bodies()
		for player in outerBodies:
			if player is Player and player.is_magnetic:
				var playerPos = player.get_global_position()
				var playerReqOrbitStability = player.reqOrbitStability
				var playerReqMagStrength = player.reqMagStrength
				set_mag_target(playerPos, playerReqOrbitStability)
				add_mag_velocity(player, playerPos, playerReqMagStrength)

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

func add_mag_velocity(player, playerPos, playerReqMagStrength):
	var magVelocityFinal = mag_velocity_lo_calc(player,playerPos).lerp(mag_velocity_hi_calc(player,playerPos),playerReqMagStrength)
	oldLookAtRotation = orbitCenter.rotation
	player.velocity += magVelocityFinal

func mag_velocity_lo_calc(player, playerPos):
	var magVector = playerPos.direction_to(targetPos)
	var distance = orbitPos.distance_to(playerPos) / global.px_to_m	#distance in meters
	var magStrength = player.fluxDensity["Lo"] * (1.33 * 3.14159 * (coreRadiusPx**3)) #field strength x volume of sphere
	var magForce = magStrength / (distance*(0.5*fieldInner.shape.radius/coreRadiusPx))
	#var magForce = magStrength / (distance**2) TRY CHANGING TO THIS ORIGINAL FORMULA
	var magAcceleration = magForce / player.mass
	var magVelocityLo = (magVector * magAcceleration * player.is_magnetic).clamp(Vector2(-1*player.maxAcceleration["Lo"],-1*player.maxAcceleration["Lo"]),Vector2(player.maxAcceleration["Lo"],player.maxAcceleration["Lo"]))
	### var orbitStability = Vector2.ZERO						### Future experiment: When traveling 
	### newDistance = playerPos.distance_to(orbitPos)			### past orbitCenter reduce forward 
	### if distance > (oldDistance / global.px_to_m):					### velocity and nudge into either CW  
	###		orbitStability = playerPos.direction_to(orbitPos)	### or CCW orbit direction, similar to
	###															### apogee/perigee orbit stabilization
	return magVelocityLo

func mag_velocity_hi_calc(player, playerPos):
	var magVector = playerPos.direction_to(targetPos)
	var distance = orbitPos.distance_to(playerPos) / global.px_to_m	#distance in meters
	var magStrength = player.fluxDensity["Hi"] * (1.33 * 3.14159 * (coreRadiusPx**3)) #field strength x volume of sphere
	var magForce = magStrength / (distance*(0.5*fieldInner.shape.radius/coreRadiusPx))
	var magAcceleration = magForce / player.mass
	var magVelocityHi = (magVector * magAcceleration * player.is_magnetic).clamp(Vector2(-1*player.maxAcceleration["Hi"],-1*player.maxAcceleration["Hi"]),Vector2(player.maxAcceleration["Hi"],player.maxAcceleration["Hi"]))
	### var orbitStability = Vector2.ZERO						### Future experiment: When traveling 
	### newDistance = playerPos.distance_to(orbitPos)			### past orbitCenter reduce forward 
	### if distance > (oldDistance / global.px_to_m):					### velocity and nudge into either CW  
	###		orbitStability = playerPos.direction_to(orbitPos)	### or CCW orbit direction, similar to
	###															### apogee/perigee orbit stabilization
	return magVelocityHi
