class_name Enemy
extends CharacterBody2D
## base class



func _on_hurtbox_area_entered(area: Area2D) -> void:
	#TODO: check body
	
	die()


func die() -> void:
	#TODO: animation
	
	queue_free()
