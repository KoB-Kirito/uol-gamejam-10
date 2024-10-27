extends Node2D

class_name Aim

@export var line : Line2D
@export var aimPoint : Node2D
@export var raycaster : RayCast2D 
@export var player : Node2D
var current_point = 1
var curPathLength = 0

var stepsCount = 50
var distanceLimit = 3000
const errorCorr = 1

func _ready():
	update_aim()

func _physics_process(delta: float) -> void:
	global_position = player.global_position
	aimPoint.global_position = get_global_mouse_position()
	
	var origin = global_position
	var dir = (get_global_mouse_position() - origin).normalized()
	var targetPoint = origin + dir * distanceLimit
	
	curPathLength = stepsCount+1
	var totalPathLength = 0
	
	for k in range(stepsCount):
		
		var i = k + 1
		line.set_point_position(i, targetPoint - line.global_position)
		
		var space_state = get_world_2d().direct_space_state
		# use global coordinates, not local to node
		#PhysicsRayQueryParameters2D.hit_from_inside = false
		var query = PhysicsRayQueryParameters2D.create(origin, targetPoint, 16)
		var result = space_state.intersect_ray(query)
	
		if !result:
			curPathLength = i+1
			for j in range(i+1, stepsCount+1):
				line.set_point_position(j, line.get_point_position(i))
			break
	
		totalPathLength += (result.position - origin).length()
		
		var normal = result.normal.normalized()
		origin = result.position + normal * errorCorr
		
		dir = dir.bounce(normal)
		targetPoint = origin + dir * max(0, distanceLimit - totalPathLength)
		
		aimPoint.global_position = result.position
		line.set_point_position(i, origin - line.global_position)
	
	return;

func get_cur_path() -> Array[Vector2]:
	var path : Array[Vector2]
	for	i in range(curPathLength):
		path.append(line.get_point_position(i) + line.global_position)
	return path
	
func setAimSettings(MaxBounces:int,MaxDistance:int):
	if(MaxBounces<1):
		MaxBounces=1
	if(MaxDistance<0):
		MaxDistance=0
	stepsCount=MaxBounces
	distanceLimit=MaxDistance
	
	update_aim()
	
func update_aim():
	line.clear_points()
	
	line.add_point(Vector2(0,0))
	line.width=1
	line.default_color=Color.RED
	for i in range(stepsCount):
		line.add_point(Vector2(0,0))
