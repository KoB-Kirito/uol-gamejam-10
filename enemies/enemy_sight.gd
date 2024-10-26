extends Node2D

@export var angleSize : float
@export var length : float

@export var debugLineLeft : Line2D
@export var debugLineRight : Line2D
@export var debugLineRay : Line2D

var player : Node2D
var playerSpotted = false

func _ready():
	debugLineLeft.add_point(Vector2(0,0))
	debugLineLeft.add_point(Vector2.from_angle(deg_to_rad(global_rotation_degrees - angleSize)) * length)
	
	debugLineRight.add_point(Vector2(0,0))
	debugLineRight.add_point(Vector2.from_angle(deg_to_rad(global_rotation_degrees + angleSize)) * length)
	
	debugLineRay.add_point(Vector2(0,0))
	debugLineRay.add_point(Vector2(0,0))
	
	player = get_tree().get_first_node_in_group(Global.playerGroup)

func _process(delta : float) -> void:	
	debugLineLeft.set_point_position(1, Vector2.from_angle(deg_to_rad(-angleSize)) * length)
	debugLineRight.set_point_position(1, Vector2.from_angle(deg_to_rad(angleSize)) * length)
	
	debugLineRay.set_point_position(1, Vector2(0,0))
	
	debugLineLeft.default_color = Color.WHITE
	debugLineRight.default_color = Color.WHITE
	
	if player == null:
		player = get_tree().get_first_node_in_group(Global.playerGroup)
		return
	
	if (player.global_position - global_position).length_squared() >= (length * length):
		return
		
	var toPlayer = player.global_position - global_position
	var forward = Vector2.from_angle(global_rotation)
	
	var angle = acos(toPlayer.dot(forward) / (toPlayer.length() * forward.length()))
	var angleDeg = rad_to_deg(angle)
	
	if angleDeg >= angleSize:
		return
		
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	
	var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position, 16)
	var result = space_state.intersect_ray(query)
	
	if result:
		debugLineRay.set_point_position(1, result.position - global_position)
		return
		
	var dir = (player.global_position - global_position).rotated(-global_rotation)
	debugLineRay.set_point_position(1, dir)
	
	debugLineLeft.default_color = Color.RED
	debugLineRight.default_color = Color.RED
		
	on_player_detected();
	
func on_player_detected():
	if playerSpotted:
		return
	print("Player has been detected. DIE!!!")
	playerSpotted = true
	
	player.die()
