extends Node2D

@onready var tip := $Sprite/Tip
@onready var animPlayer := $AnimationPlayer

func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())

func shoot() -> void:
	animPlayer.stop()
	animPlayer.play("shoot")
