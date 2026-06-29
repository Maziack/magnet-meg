extends Node

var px_to_m: float = 30.48
var delta:float

func _physics_process(_delta: float) -> void:
	delta = _delta * 60
