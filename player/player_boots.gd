extends Node2D

@export var footprints : PackedScene
@export var dst_between : float
var curDst = 0.0
var prevPos : Vector2

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
		curDst -= dst_between
		
	prevPos = curPos
