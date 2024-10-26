extends Node2D

@export var lifetime : float
@export var sprite : Sprite2D

var t : float

func _ready() -> void:
	t = 0.0
	
func _process(delta: float) -> void:
	t += delta
	
	sprite.modulate.a = 1 - (t / lifetime)
	
	if t >= lifetime:
		queue_free()
