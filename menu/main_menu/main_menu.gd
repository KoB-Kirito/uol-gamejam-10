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
	%StartButton.mouse_exited.disconnect(_on_start_button_mouse_exited)
	%StartButton.pressed.disconnect(_on_start_button_pressed)
	$OptionsButton.mouse_exited.disconnect(_on_options_button_mouse_exited)
	$ExitButton.mouse_exited.disconnect(_on_exit_button_mouse_exited)
	
	%snd_select.play()
	%Blood.show()
	
	Bgm.fade_out(0.5)
	
	await get_tree().create_timer(1.5).timeout
	
	# start normal game
	PauseMenu.enable()
	
	SceneTransition.fade_out_change_scene(next_level)


func _on_free_button_pressed() -> void:
	#TODO: add second playmode
	pass


func _on_options_button_pressed() -> void:
	%OptionsMenu.show()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
	#TODO: Does nothing on web


func _on_start_button_mouse_entered() -> void:
	%snd_hover.play()
	%StartHover.show()

func _on_start_button_mouse_exited() -> void:
	%StartHover.hide()


func _on_options_button_mouse_entered() -> void:
	%snd_hover.play()
	%StartHover2.show()

func _on_options_button_mouse_exited() -> void:
	%StartHover2.hide()


func _on_exit_button_mouse_entered() -> void:
	%snd_hover.play()
	%StartHover3.show()

func _on_exit_button_mouse_exited() -> void:
	%StartHover3.hide()
