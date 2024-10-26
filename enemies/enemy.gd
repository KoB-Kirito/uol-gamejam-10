class_name Enemy
extends CharacterBody2D
## base class

@export var path : EnemyPath
@export var moveSpeed : int

@onready var timer = $Timer

var pathPoints : Array[Vector2]
var curNode = 0
var advanceFlag = false
var t = 0

var canMove = true

signal died(enemy: Enemy)

func _ready() -> void:
	if path == null:
		canMove = false
		return
	
	pathPoints = path.get_path_points()
	
	advance()

func _process(delta: float) -> void:
	if !canMove:
		return
	
	var flagCalled = false
	
	if advanceFlag:
		advanceFlag = false
		t += moveSpeed * delta
		flagCalled = true
	if t == 0.0:
		return
	
	if !flagCalled:
		t += moveSpeed * delta
	
	var nextNode = (curNode + 1)
	if nextNode >= pathPoints.size() - 1:
		nextNode = 0
	var subPath = (pathPoints[nextNode] - pathPoints[curNode])
	
	if subPath.length() <= t:
		global_position = pathPoints[nextNode]
		t = 0.0
		curNode = nextNode
		
		timer.start(path.get_wait_time(curNode))
		print(path.get_wait_time(curNode))
		return
		
	var newPos = pathPoints[curNode] + subPath.normalized() * t
	global_position = newPos
	
	var angleRad = acos(subPath.dot(Vector2(1,0)) / (subPath.length()))
	if subPath.dot(Vector2(0,1)) < 0:
		angleRad *= -1
	global_rotation = angleRad

func advance():
	advanceFlag = true

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group(Global.playerGroup):
		body.die()
		return
	
	if body is not Bullet:
		return
	
	die()

func die() -> void:
	#TODO: animation
	
	died.emit(self)
	queue_free()


func _on_timer_timeout() -> void:
	advance()
	pass # Replace with function body.
