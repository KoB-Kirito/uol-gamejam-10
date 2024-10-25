extends Node2D

@export var bulletSpeed: int = 500

func _physics_process(delta: float) -> void:
	position.x += cos(rotation) * bulletSpeed * delta
	position.y += sin(rotation) * bulletSpeed * delta
