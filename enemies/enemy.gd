class_name Enemy
extends CharacterBody2D
## base class

@export_group("Movement")
@export var path : EnemyPath
@export var moveSpeed : int
@export var turnSpeed : float
@export var maxTurnTime : float

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

@export_group("On alert")
@export var moveSpeedMultiplier : float
@export var turnSpeedMultiplier : float
@export var observingInterval : float
@export var observingChance : float

@export_group("Other")
@export var corpse : PackedScene

@onready var timer = $Timer
@onready var turnTimer = $TurnTimer
@onready var observTimer = $ObservTimer
@onready var susTimer = $SusTimer

var pathPoints : Array[Vector2]
var curNode = 0
var advanceFlag = false
var t = 0.0
var canMove = true

var rng = RandomNumberGenerator.new()

var is_waiting = false
var isObserving = false
var isOnAlert = false

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

var current_direction: Vector2 = Vector2.ZERO
var prevPosition : Vector2

var observTimerDone = true
var susTimerDone = true

signal died(enemy: Enemy)

func _ready() -> void:
	if path == null:
		canMove = false
		return
	
	path.update_path()
	pathPoints = path.get_path_points()
	
	advance()


func _process(delta: float) -> void:
	# animation
	
	# get movement
	var movement_type: String
	if current_direction == Vector2.ZERO:
		movement_type = "idle"
		
	else:
		movement_type = "walk"
	
	# get direction
	var direction: String
	var r: float = global_rotation_degrees
	match true:
		_ when (r >= 45 and r < 135) or (r >= -315 and r < -225):
			direction = "down"
		
		_ when abs(r) >= 135 and abs(r) < 225:
			direction = "left"
		
		_ when (r >= 225 and r < 315) or (r >= -135 and r < -45):
			direction = "up"
			
		_: # else
			direction = "right"
	
	# play animation
	%AnimatedSprite2D.play(direction + "_" + movement_type)


func _physics_process(delta: float) -> void:
	#HACK: let sprite follow to keep rotation
	%AnimatedSprite2D.position = position
	
	if cdInv > 0.0:
		cdInv = max(0, cdInv - delta)
	
	if is_turning:
		current_direction = Vector2.ZERO
		
		var tSpeed = turnSpeed
		if isOnAlert || isObserving:
			tSpeed *= turnSpeedMultiplier
		curRotation += delta * tSpeed
		
		global_rotation = rotate_toward(initRotation, desRotation, curRotation)

		var iRP = initRotation
		var dRP = desRotation
		if initRotation < 0:
			iRP = initRotation + (2*PI * (floor(-initRotation / (2*PI)) + 1))		
		if desRotation < 0:
			dRP = desRotation + (2*PI * (floor(-initRotation / (2*PI)) + 1))
		
		var d = abs(dRP - iRP)
		if d > 2*PI:
			d -= 2*PI
			
		if curRotation >= d:
			global_rotation = desRotation
			is_turning = false
		return
	
	if isObserving:
		current_direction = Vector2.ZERO
		
		if is_turning:
			return
		
		if !observTimerDone:
			return
		
		var rnd = rng.randf()
		if rnd < observingChance:
			return
		
		observTimerDone = false
		
		var angle = rng.randf_range(PI/2.0, PI)
		if rng.randf() > .5:
			angle *= -1
		angle += global_rotation
		turn(Vector2.from_angle(angle))
		
		observTimer.stop()
		observTimer.start(observingInterval)
		
		return
	
	if !canMove && !is_investigating:
		current_direction = Vector2.ZERO
		
		if is_turning:
			return
			
		if !susTimerDone:
			return
		
		var rnd = rng.randf()
		if rnd < randomSuspicionChance:
			return
		
		susTimerDone = false
		
		var angle = rng.randf_range(PI/2.0, PI)
		if rng.randf() > .5:
			angle *= -1
		angle += global_rotation
		turn(Vector2.from_angle(angle))
		
		susTimer.stop()
		susTimer.start(randomSuspicionInterval)
		
		return
	
	if is_waiting:
		current_direction = Vector2.ZERO
		return
	
	if is_investigating:
		investigateMove(delta)
	else:
		patrol(delta)
	
	current_direction = prevPosition.direction_to(global_position)
	prevPosition = global_position

func advance():
	advanceFlag = true
	
	var nextNode = (curNode + 1)
	if nextNode >= pathPoints.size():
		nextNode = 0
	
	var subPath = Vector2(0,0)
	
	if is_investigating:
		subPath = (curPOI - backtrackStack[backtrackStack.size() - 1])
	elif canMove:
		subPath = (pathPoints[nextNode] - pathPoints[curNode])
	
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
	var newCorpse = corpse.instantiate()
	get_parent().add_child(newCorpse)
	newCorpse.global_position = global_position
	
	died.emit(self)
	queue_free()

func wait(duration : float):
	timer.stop()
	is_waiting = true
	timer.start(duration)

func _on_timer_timeout() -> void:
	timer.stop()
	is_waiting = false
	isObserving = false
	
	observTimer.stop()
	observTimerDone = true
	susTimer.stop()
	susTimerDone = true
	
	is_turning = false
	
	if !is_returning:
		advance()
	else:
		var subPath = (curPOI - backtrackStack[backtrackStack.size() - 1])
		turn(subPath)

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
	move_and_slide()
	

func investigateMove(delta : float):	
	var mSpeed = moveSpeed
	if isOnAlert:
		mSpeed *= moveSpeedMultiplier
	tInv += mSpeed * delta
	
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
		
		subPath = (curPOI - backtrackStack[backtrackStack.size() - 1])
		turn(subPath)
		
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
	
	isOnAlert = true
	isObserving = false
	observTimer.stop()
	observTimerDone = true
	susTimer.stop()
	susTimerDone = true
	
	wait(newInvestigationPause)

func reach_investigation():
	var oldPOI = curPOI
	curPOI = backtrackStack.pop_back()
	backtrackStack.append(oldPOI)
		
	tInv = 0.0
	is_returning = true
	
	isOnAlert = false
	isObserving = true
	wait(investigationDuration)

func finish_investigation():
	is_returning = false
	is_investigating = false
	
	backtrackStack.clear()
	
	wait(finishInvestigationPause)

func turn(desDir : Vector2):
	var angleRad = acos(desDir.dot(Vector2(1,0)) / (desDir.length()))
	
	if desDir.dot(Vector2(0,1)) < 0:
		angleRad *= -1
	desRotation = angleRad
	
	is_turning = true
	initRotation = global_rotation
	curRotation = 0.0
	
	turnTimer.stop()
	turnTimer.start(maxTurnTime)

func _on_turn_timer_timeout() -> void:
	is_turning = false

func _on_observ_timer_timeout() -> void:
	observTimerDone = true
	
	if !isObserving:
		return

func _on_sus_timer_timeout() -> void:
	susTimerDone = true
