extends Node2D

@export var player : Player
@export var footprints : PackedScene
@export var dst_between : float
@export var spawnOffset : float
var curDst = 0.0
var prevPos : Vector2

var k = 0

func _ready():
	prevPos = global_position

func _process(delta : float) -> void:
	var curPos = global_position
	var diff = curPos - prevPos
	curDst += diff.length()
	
	if curDst >= dst_between:
		var newPrints = footprints.instantiate()
		add_child(newPrints)
		newPrints.global_position = global_position
		newPrints.global_rotation = player.velocity.angle()
		curDst -= dst_between
		
		if k % 2 == 0:
			newPrints.position += Vector2(-spawnOffset, 0)
		else:
			newPrints.position += Vector2(spawnOffset, 0)
		
		k += 1
		
	prevPos = curPos
