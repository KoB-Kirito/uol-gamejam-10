class_name Enemy
extends CharacterBody2D
## base class


signal died(enemy: Enemy)


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is not Bullet:
		return
	
	die()


func die() -> void:
	#TODO: animation
	
	died.emit(self)
	queue_free()
