extends TabBar


const WINDOW_MODES = [
		"Fullscreen",
		"Borderless",
		"Windowed",
]

const RESOLUTIONS = {
		"640 x 640"   : Vector2i(640, 640),
		"960 x 960"  : Vector2i(960, 960),
		"1080 x 1080" : Vector2i(1080, 1080),
		"1440 x 1440" : Vector2i(1440, 1440),
		"2160 x 2160" : Vector2i(2160, 2160),
}


func _ready() -> void:
	setup_video_options()


func setup_video_options() -> void:
	# window mode
	for mode in WINDOW_MODES:
		%WindowModeOptionButton.add_item(mode)
	
	var current_mode := DisplayServer.window_get_mode()
	match current_mode:
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			%WindowModeOptionButton.select(0)
			%ResolutionOptionButton.disabled = true
		
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			%WindowModeOptionButton.select(1)
			%ResolutionOptionButton.disabled = true
		
		DisplayServer.WINDOW_MODE_WINDOWED:
			%WindowModeOptionButton.select(2)
	
	# resolution
	for resolution in RESOLUTIONS:
		%ResolutionOptionButton.add_item(resolution)
	
	#TODO: Select option if available
	%ResolutionOptionButton.text = get_screen_size_string()


func _on_window_mode_option_button_item_selected(index: int) -> void:
	match index:
		0: # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			%ResolutionOptionButton.disabled = true
			%ResolutionOptionButton.text = get_screen_size_string()
		
		1: # Borderless
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			%ResolutionOptionButton.disabled = true
			%ResolutionOptionButton.text = get_screen_size_string()
		
		2: # Window
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			%ResolutionOptionButton.disabled = false
			%ResolutionOptionButton.text = get_screen_size_string()


func get_screen_size_string() -> String:
	var screen_size := DisplayServer.window_get_size()
	return str(screen_size.x) + " x " + str(screen_size.y)


func _on_resolution_option_button_item_selected(index: int) -> void:
	DisplayServer.window_set_size(RESOLUTIONS.values()[index])
