extends CharacterBody2D

class_name Bullet

@export var bulletSpeed: int = 500

var curDir : Vector2



func _physics_process(delta: float) -> void:
	#position += curDir * bulletSpeed * delta
	
	
	
		var c = move_and_collide(velocity*delta)
		if c != null:
			var normal = c.get_normal()
			print("---------------")
			print(velocity)
			velocity = velocity.bounce(normal)
			#var newAng = velocity.angle + 2*velocity.angle - 2*normal.angle
			#velocity = Vector2.from_angle(newAng)
			print(velocity)
	#Vector2.from_angle()
	

func get_translation() -> Vector2:
	return Vector2(position.x + cos(rotation), position.y + sin(rotation)) * bulletSpeed

func launch() -> void:
	velocity.x = cos(rotation) * bulletSpeed
	velocity.y = sin(rotation) * bulletSpeed
	print(rotation)
	print(sin(rotation))
	


	
	
	
	#print(Vector2.from_angle(area.rotation))
	#launch(curDir.bounce(Vector2.from_angle(area.rotation)))
