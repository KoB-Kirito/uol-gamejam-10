class_name Enemy
extends CharacterBody2D
## base class

@export_group("Movement")
@export var path : EnemyPath
@export var moveSpeed : int
@export var turnSpeed : float

@export_group("Waiting times")
@export var defaultPatrolPause : float
@export var investigationDuration : float
@export var newInvestigationPause : float
@export var finishInvestigationPause : float
@export var randomSuspicionPause : float

@export_group("Investigation and senses")
@export var canSee = true
@export var blindnessRadius : float
@export var investigationCooldown : float
@export var randomSuspicionInterval : float
@export var randomSuspicionChance : float

@onready var timer = $Timer

var pathPoints : Array[Vector2]
var curNode = 0
var advanceFlag = false
var t = 0.0
var canMove = true

var susT = 0.0
var rng = RandomNumberGenerator.new()

var tInv = 0.0
var cdInv = 0.0
var is_investigating = false
var is_returning = false
var backtrackStack : Array[Vector2]
var curPOI : Vector2

var desRotation = 0.0
var curRotation = 0.0
var initRotation = 0.0
var is_turning = false

var is_waiting = false

signal died(enemy: Enemy)

func _ready() -> void:
	if path == null:
		canMove = false
		return
	
	path.update_path()
	pathPoints = path.get_path_points()
	
	advance()


func _process(delta: float) -> void:
	#TODO: animation
	pass


func _physics_process(delta: float) -> void:
	#HACK: let sprite follow to keep rotation
	%AnimatedSprite2D.position = position
	
	if !canMove || is_waiting:
		return
	
	if is_turning:
		curRotation += delta * turnSpeed
		
		global_rotation = rotate_toward(initRotation, desRotation, curRotation)
		
		if curRotation >= abs(desRotation - initRotation):
			global_rotation = desRotation
			is_turning = false
		return
		
	
	if is_investigating:
		investigateMove(delta)
	else:
		patrol(delta)

func advance():
	advanceFlag = true
	
	var nextNode = (curNode + 1)
	if nextNode >= pathPoints.size():
		nextNode = 0
	
	var subPath = (pathPoints[nextNode] - pathPoints[curNode])
	
	if is_investigating:
		subPath = (curPOI - backtrackStack[backtrackStack.size() - 1])
	
	turn(subPath)

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

func wait(duration : float):
	is_waiting = true
	timer.start(duration)

func _on_timer_timeout() -> void:
	timer.stop()
	is_waiting = false
	advance()

func patrol(delta : float):
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
	if nextNode >= pathPoints.size():
		nextNode = 0
	
	var subPath = (pathPoints[nextNode] - pathPoints[curNode])
	
	if subPath.length() <= t:
		global_position = pathPoints[nextNode]
		t = 0.0
		curNode = nextNode
		
		var time = path.get_wait_time(curNode)
		if time <= 0:
			wait(defaultPatrolPause)
		else:
			wait(path.get_wait_time(curNode))
		
		return
		
	var newPos = pathPoints[curNode] + subPath.normalized() * t
	global_position = newPos
	
	susT += delta
	if susT >= randomSuspicionInterval:
		susT = 0.0
		check_rand_suspicion()

func investigateMove(delta : float):
	if cdInv > 0.0:
		cdInv = max(0, cdInv - delta)
	
	tInv += moveSpeed * delta
	
	var subPath = (curPOI - backtrackStack[backtrackStack.size() - 1])
	
	if subPath.length() <= tInv:
		if !is_returning:
			reach_investigation()
			return
		
		if backtrackStack.size() == 1:
			finish_investigation()
			return;
		
		var oldPOI = curPOI
		backtrackStack.pop_back()
		curPOI = backtrackStack.pop_back()
		backtrackStack.append(oldPOI)
		
		tInv = 0.0
		return
		
	var newPos = backtrackStack[backtrackStack.size() - 1] + subPath.normalized() * tInv
	global_position = newPos

func investigate(pos : Vector2):
	if cdInv > 0.0:
		return
		
	if (curPOI - pos).length_squared() <= blindnessRadius * blindnessRadius:
		return
	
	if is_returning:
		backtrackStack.pop_back()
		backtrackStack.append(curPOI)
		is_returning = false
	
	backtrackStack.append(global_position)
	curPOI = pos
	is_investigating = true
	tInv = 0.0
	
	cdInv = investigationCooldown
	
	if is_turning:
		is_turning = false
	
	wait(newInvestigationPause)

func reach_investigation():
	var oldPOI = curPOI
	curPOI = backtrackStack.pop_back()
	backtrackStack.append(oldPOI)
		
	tInv = 0.0
	is_returning = true
	
	wait(investigationDuration)

func finish_investigation():
	is_returning = false
	is_investigating = false
	
	backtrackStack.clear()
	
	wait(finishInvestigationPause)
	
func check_rand_suspicion():
	var rnd = rng.randf()
	
	if rnd > randomSuspicionChance:
		return
	
	wait(randomSuspicionPause)

func turn(desDir : Vector2):
	var angleRad = acos(desDir.dot(Vector2(1,0)) / (desDir.length()))
	
	if desDir.dot(Vector2(0,1)) < 0:
		angleRad *= -1
	desRotation = angleRad
	
	is_turning = true
	initRotation = global_rotation
	curRotation = 0.0
