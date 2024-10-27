extends Node2D

@export var angleSize : float
@export var length : float

@export var base_enemy : Enemy

@export var debugLineLeft : Line2D
@export var debugLineRight : Line2D
@export var showDebug : bool

var player : Node2D
var playerSpotted = false

func _draw():
	if !showDebug:
		return
	
	if get_tree() == null:
		return
	
	var footprints = get_tree().get_nodes_in_group(Global.footprintGroup)
	
	if footprints == null:
		return
	
	var youngest
	var lifetime = INF

	var parent: CanvasItem = get_parent()
	var global_to_local: Transform2D = get_global_transform().affine_inverse()
	
	for	f in footprints:
		if (f.global_position - global_position).length_squared() >= (length * length):
			#draw_line(Vector2(0,0), global_to_local * f.global_position,Color.AQUA)
			continue
		
		var toTarget = f.global_position - global_position
		var forward = Vector2.from_angle(global_rotation)
		
		var angle = acos(toTarget.dot(forward) / (toTarget.length() * forward.length()))
		var angleDeg = rad_to_deg(angle)
		
		if angleDeg >= angleSize:
			#draw_line(Vector2(0,0), global_to_local * f.global_position,Color.GREEN)
			continue
			
		var space_state = get_world_2d().direct_space_state
		# use global coordinates, not local to node
		
		var query = PhysicsRayQueryParameters2D.create(global_position, f.global_position, 17)
		var result = space_state.intersect_ray(query)
		
		if result:
			draw_line(Vector2(0,0), global_to_local * f.global_position,Color.GREEN)
			continue
			
		var dir = (f.global_position - global_position).rotated(-global_rotation)
		draw_line(Vector2(0,0), global_to_local * f.global_position,Color.RED)

func _ready():
	debugLineLeft.add_point(Vector2(0,0))
	debugLineLeft.add_point(Vector2.from_angle(deg_to_rad(global_rotation_degrees - angleSize)) * length)
	
	debugLineRight.add_point(Vector2(0,0))
	debugLineRight.add_point(Vector2.from_angle(deg_to_rad(global_rotation_degrees + angleSize)) * length)
	
	player = get_tree().get_first_node_in_group(Global.playerGroup)

func _process(delta : float) -> void:
	if showDebug:
		queue_redraw()
	
	if !base_enemy.canSee:
		return
	
	debugLineLeft.set_point_position(1, Vector2.from_angle(deg_to_rad(-angleSize)) * length)
	debugLineRight.set_point_position(1, Vector2.from_angle(deg_to_rad(angleSize)) * length)
	
	debugLineLeft.default_color = Color.WHITE
	debugLineRight.default_color = Color.WHITE
	
	if get_tree() == null || player == null:
		player = get_tree().get_first_node_in_group(Global.playerGroup)
		return
		
	var playerSpotted = try_see_object(player)
	if playerSpotted:
		on_player_detected()
	
	if get_tree() == null:
		return
	
	var footprints = get_tree().get_nodes_in_group(Global.footprintGroup)
	
	var youngest
	var lifetime = INF
	for	f in footprints:
		if !try_see_object(f):
			continue
		if (f.t / f.lifetime) < lifetime:
			youngest = f
			lifetime = (f.t / f.lifetime)
	
	if youngest != null:
		base_enemy.investigate(youngest.global_position)
	
func try_see_object(target : Node2D) -> bool:
	if (target.global_position - global_position).length_squared() >= (length * length):
		return false
		
	var toTarget = target.global_position - global_position
	var forward = Vector2.from_angle(global_rotation)
	
	var angle = acos(toTarget.dot(forward) / (toTarget.length() * forward.length()))
	var angleDeg = rad_to_deg(angle)
	
	if angleDeg >= angleSize:
		return false
		
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	
	var query = PhysicsRayQueryParameters2D.create(global_position, target.global_position, 16)
	var result = space_state.intersect_ray(query)
	
	if result:
		return false
		
	var dir = (target.global_position - global_position).rotated(-global_rotation)
	
	return true;

func on_player_detected():
	if playerSpotted:
		return
	
	playerSpotted = true
	player.die()
