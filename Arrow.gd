extends Bullet

@onready var area: Area2D = $Area2D

var IsTraveling:bool=true
func _ready() -> void:
	area.monitoring=false
func _process(delta: float) -> void:
	if not IsTraveling :
		return
		
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
		dropArrow()
		return

	var progress = (newDst - totalDistances[newBegin]) / (totalDistances[end] - totalDistances[newBegin])
	var newPos = (path[end] - path[newBegin]) * progress + path[newBegin]
	
	totalDst = totalDistances[newBegin] + (path[end] - path[newBegin]).length() * progress
	global_position = newPos

func dropArrow():
	IsTraveling=true
	area.monitoring=true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
		
	queue_free()
	body.gun.hasBullet=true
	
