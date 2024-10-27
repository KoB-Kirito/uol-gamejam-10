class_name Player
extends CharacterBody2D

@export var speed = 200
@export var friction = 0.01
@export var acceleration = 0.1
@onready var gun=null
@export var aim : Aim


func _ready() -> void:
	aim.setAimSettings(1,0)
	
func die() -> void:
	get_tree().reload_current_scene()
	
func get_input():
	var input = Vector2()
	if Input.is_action_pressed('right'):
		input.x += 1
	if Input.is_action_pressed('left'):
		input.x -= 1
	if Input.is_action_pressed('down'):
		input.y += 1
	if Input.is_action_pressed('up'):
		input.y -= 1
	return input

func _physics_process(delta):
	var direction = get_input()
	if direction.length() > 0:
		velocity = velocity.lerp(direction.normalized() * speed, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction)
	move_and_slide()
	if gun == null :
		return
	if Input.is_action_just_pressed("shoot") :
		# Knockback
		if not gun.shoot(aim.get_cur_path()):
			return
		var r = gun.rotation + PI
		velocity += Vector2(cos(r), sin(r)) * gun.knockback
		
