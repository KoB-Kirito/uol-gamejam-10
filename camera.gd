extends Camera2D


@export var smoothing: float = 0.5
@export var max_distance: float = 100.0
@export var player: Player

var screen_center: Vector2


func _ready() -> void:
	screen_center = get_viewport_rect().size / 2


func _process(delta: float) -> void:
	var mouse_position := get_viewport().get_mouse_position()
	var direction := screen_center.direction_to(mouse_position)
	var distance := screen_center.distance_to(mouse_position) * smoothing
	
	#printt(screen_center, mouse_position, direction, distance)
	
	if distance < max_distance:
		global_position = player.global_position + direction * distance
		
	else:
		global_position = player.global_position + direction * max_distance
