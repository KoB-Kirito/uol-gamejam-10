class_name KeybindOption
extends HBoxContainer


const UNASSIGNED: String = "-"

var action_name: String
var events: Array[InputEventKey]

static var active_button: Button = null
static var active_button_text: String = ""


func _ready() -> void:
	if not action_name:
		return
	
	#TODO: Support more than three?
	if events.size() != 3:
		events.resize(3)
	
	%Label.text = action_name.to_pascal_case() #TODO: Improve: move_left to Move Left
	setup_button_labels()
	
	%Button1.pressed.connect(on_button_pressed.bind(%Button1))
	%Button2.pressed.connect(on_button_pressed.bind(%Button2))
	%Button3.pressed.connect(on_button_pressed.bind(%Button3))


func setup_button_labels() -> void:
	if events[0]:
		if events[0].keycode:
			printt(events[0].keycode, events[0].physical_keycode)
		%Button1.text = OS.get_keycode_string(events[0].physical_keycode)
	else:
		%Button1.text = UNASSIGNED
	
	if events[1]:
		%Button2.text = OS.get_keycode_string(events[1].physical_keycode)
	else:
		%Button2.text = UNASSIGNED
	
	if events[2]:
		%Button3.text = OS.get_keycode_string(events[2].physical_keycode)
	else:
		%Button3.text = UNASSIGNED


func on_button_pressed(button: Button) -> void:
	# current active button canceled
	if button == active_button:
		active_button.text = active_button_text
		active_button = null
		return
	
	button.release_focus()
	
	# if another button is active disable it
	if active_button:
		active_button.button_pressed = false
		active_button.text = active_button_text
	
	active_button_text = button.text
	button.text = "Press any key..."
	active_button = button


func _unhandled_key_input(event: InputEvent) -> void:
	# only handle key down
	if not event.is_pressed():
		return
	
	# only handle if a button is active
	if not active_button:
		return
	
	# only handle if one of own buttons is active
	if active_button != %Button1 and active_button != %Button2 and active_button != %Button3:
		return
	
	# only handle if event is key event
	var key_event := event as InputEventKey
	if not key_event:
		return
	
	var active_button_index := get_active_button_index()
	
	# unbind
	if key_event.physical_keycode == KEY_DELETE or key_event.physical_keycode == KEY_BACKSPACE:
		events[active_button_index] = null
		active_button.button_pressed = false
		active_button.text = UNASSIGNED
		active_button.grab_focus()
		active_button = null
		return
	
	# unbind old key
	if events.size() > active_button_index and events[active_button_index]:
		InputMap.action_erase_event(action_name, events[active_button_index])
	
	# add new key
	InputMap.action_add_event(action_name, key_event)
	events[active_button_index] = key_event
	
	# reset button
	active_button.button_pressed = false
	active_button.text = OS.get_keycode_string(key_event.physical_keycode)
	active_button.grab_focus()
	active_button = null


func get_active_button_index() -> int:
	if active_button == %Button1:
		return 0
		
	elif active_button == %Button2:
		return 1
		
	elif active_button == %Button3:
		return 2
	
	return -1
