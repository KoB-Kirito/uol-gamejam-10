extends CharacterBody2D

@export var speed = 200
@export var friction = 0.01
@export var acceleration = 0.1
@onready var gun := $Gun
@export var aim : Aim

var hasShot = false
@export var knockback = 200

@onready var bullet = preload("res://bullet.tscn")

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
	
	if Input.is_action_just_pressed("shoot") :#&& !hasShot:
		# Knockback
		var r = gun.rotation + PI
		velocity += Vector2(cos(r), sin(r)) * knockback
	
		gun.shoot()
		hasShot = true
		
		var b = bullet.instantiate()
		get_parent().add_child(b)
		b.position = gun.tip.global_position
		b.rotation = gun.rotation
		
		b.launch(aim.get_cur_path())
