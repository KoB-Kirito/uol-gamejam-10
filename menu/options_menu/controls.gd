extends TabBar


const keybind_option_scene = preload("res://menu/options_menu/keybind_option.tscn")


func _ready() -> void:
	# clear placeholders
	for child in %KeybindOptionContainer.get_children():
		child.queue_free()
	
	# create from data
	for action_name in InputMap.get_actions():
		# ignore built-in
		if action_name.begins_with("ui_"):
			continue
		
		# blacklist
		if action_name.begins_with("dialogic"):
			continue
		
		var keybind_option: KeybindOption = keybind_option_scene.instantiate()
		keybind_option.action_name = action_name
		for event in InputMap.action_get_events(action_name):
			if event is InputEventKey:
				keybind_option.events.append(event)
			else:
				push_warning("Event is not a key event, will not be added to options: ", event.to_string())
		%KeybindOptionContainer.add_child(keybind_option)
