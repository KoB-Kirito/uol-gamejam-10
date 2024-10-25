extends Node2D

@onready var tip := $Sprite/Tip
@onready var animPlayer := $AnimationPlayer
@onready var sprite := $Sprite

func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())
	var normDir = int(rotation_degrees) % 360
	if normDir > 90 and normDir < 270:
		sprite.flip_v = true
	else:
		sprite.flip_v = false

func shoot() -> void:
	animPlayer.stop()
	animPlayer.play("shoot")
		
