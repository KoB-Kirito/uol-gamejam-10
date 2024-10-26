extends Control


## Scene that is loaded when start button is pressed
@export var next_level: TransitionDataOut

@export_group("BGM")
@export var bgm: AudioStream
@export var volume_db: float = 0.0


func _ready() -> void:
	SceneTransition.fade_in()
	
	PauseMenu.enabled = false
	
	if bgm:
		Bgm.fade_to(bgm, volume_db, 0.0)


func _on_start_button_pressed() -> void:
	# start normal game
	PauseMenu.enable()
	
	Bgm.fade_out(0.5)
	
	SceneTransition.fade_out_change_scene(next_level)


func _on_free_button_pressed() -> void:
	#TODO: add second playmode
	pass


func _on_options_button_pressed() -> void:
	%OptionsMenu.show()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
	#TODO: Does nothing on web
