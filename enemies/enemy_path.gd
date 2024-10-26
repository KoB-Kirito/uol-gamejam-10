extends Node2D

class_name EnemyPath

@export var pathNodesParent : Node2D
@export var pathPoints : Array[Vector2]
@export var waitTimes : Array[float]
@export var debugLine : Line2D

func _ready() -> void:
	update_path()

func update_path():
	if pathNodesParent == null:
		return
	
	pathPoints.clear()
	for c in pathNodesParent.get_children():
		pathPoints.append(c.global_position)
	
	pathPoints.append(pathPoints[0])
	
	if debugLine == null:
		return
	for p in pathPoints:
		debugLine.add_point(p - debugLine.global_position)

func get_path_points() -> Array[Vector2]:
	return pathPoints
func get_wait_time(index : int) -> float:
	return waitTimes[index]
