extends Node2D

@export var lifetime : float
@export var sprite : Sprite2D

@onready var fp1 = preload("res://player/Fu_2..png")
@onready var fp2 = preload("res://player/Fu_3..png")

var t : float
@onready var rng = RandomNumberGenerator.new()

func _ready() -> void:
	t = 0.0
	
	if rng.randf() > .5:
		sprite.texture = fp1
	else:
		sprite.texture = fp2
	
func _process(delta: float) -> void:
	t += delta
	
	sprite.modulate.a = 1 - (t / lifetime)
	
	if t >= lifetime:
		queue_free()
