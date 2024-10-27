extends Control
## Endscreen


func _ready() -> void:
	var endtime := Speedrun.stop()
	%Label.text = "Time: " + endtime


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed():
		get_tree().change_scene_to_file("res://menu/main_menu/main_menu.tscn")
