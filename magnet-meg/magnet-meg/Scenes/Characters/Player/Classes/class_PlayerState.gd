class_name PlayerState
extends State

const IDLE = "Idle"
const RUNNING = "Running"
const JUMPING = "Jumping"
const FALLING = "Falling"
const NORMAL = "Normal"
const MAGNETIC = "Magnetic"

var player: Player
var animation: Dictionary = {"-1":"move_left", "1":"move_right"}


func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")
