extends Node2D

#@onready var bullet = preload("res://bullet.tscn")
@export var bullet : PackedScene
@export var knockback :float
@onready var tip := $Sprite/Tip
@onready var animPlayer := $AnimationPlayer
@onready var sprite := $Sprite
@onready var area:= $Area2D

@export var IsEquipped:bool
@export var AimBounces:int
@export var AimRange:int

var hasBullet:bool=true

func _physics_process(delta: float) -> void:
	if not IsEquipped:
		return
	look_at(get_global_mouse_position())
	var normDir = int(rotation_degrees) % 360
	if normDir > 90 and normDir < 270:
		sprite.flip_v = true
	else:
		sprite.flip_v = false

func shoot(path:Array[Vector2]) -> bool:
	if not hasBullet:
		return false
	animPlayer.stop()
	animPlayer.play("shoot")
	
	var b = bullet.instantiate()
	get_tree().root.add_child(b)
	b.position = tip.global_position
	b.rotation = rotation
	
	b.launch(path)
	hasBullet=false
	return true
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Enemy:
		return
	if body == get_parent():
		area.queue_free()
		return
	if body.gun!=null:
		queue_free()
		return
	reparent(body)
	position=Vector2(0,0)	
	body.gun=self
	body.aim.setAimSettings(AimBounces,AimRange)
	
	IsEquipped=true
	area.queue_free()
