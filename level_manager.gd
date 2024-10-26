extends Node
## LevelManager


signal enemy_died(enemy)
#signal all_enemies_died

@export var camBoundBotRight : Vector2
@export var camBoundTopLeft : Vector2
@export_file("*.tscn") var next_level: String

var enemies: Array[Enemy]
var player : Node2D

func _ready() -> void:
	var camera = get_tree().get_first_node_in_group(Global.cameraGroup)
	if camera != null:
		camera.limit_right = camBoundBotRight.x
		camera.limit_bottom = camBoundBotRight.y
		camera.limit_left = camBoundTopLeft.x
		camera.limit_top = camBoundTopLeft.y
	
	# store all enemies
	for enemy in get_tree().get_nodes_in_group("enemy"):
		# store enemy
		enemies.append(enemy)
		
		# connect died event
		enemy.died.connect(on_enemy_died)
	
	print_debug("found ", enemies.size(), " enemies")
	
	SceneTransition.fade_in()


func on_enemy_died(enemy: Enemy) -> void:
	enemies.erase(enemy)
	
	enemy_died.emit(enemy)
	
	if not enemies:
		#all_enemies_died.emit()
		win_level()


func win_level():
	# show scoreboard
	%ScoreboardLayer.show()


func _on_scoreboard_gui_input(event: InputEvent) -> void:
	if event.is_pressed():
		get_tree().change_scene_to_file(next_level)
