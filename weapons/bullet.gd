extends CharacterBody2D

class_name Bullet

var path : Array[Vector2]
var totalDistances : Array[float]
var totalDst : float

@export var bulletSpeed = 200


func _process(delta: float) -> void:
	var speed = bulletSpeed * delta
	var newDst = totalDst + speed
	
	var newBegin = 0
	for i in range(totalDistances.size()):		
		if totalDistances[i] < newDst:
			newBegin = i
			continue
		
		break
	
	
	var end = newBegin + 1

	if end >= totalDistances.size():
		queue_free()
		return

	var progress = (newDst - totalDistances[newBegin]) / (totalDistances[end] - totalDistances[newBegin])
	var newPos = (path[end] - path[newBegin]) * progress + path[newBegin]
	
	totalDst = totalDistances[newBegin] + (path[end] - path[newBegin]).length() * progress
	global_position = newPos
	
func launch(path : Array[Vector2]):
	
	self.path = path
	
	totalDistances.append(0.0)
	for i in range(1, path.size()):
		var prev = totalDistances[i - 1]
		var new = prev + (path[i] - path[i-1]).length()
		totalDistances.append(new)
	
