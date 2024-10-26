extends CanvasLayer


const MARGIN = 10

enum Transition {
	SLIDE,
	FADE,
	}

## Fires when transition is finished
signal finished


func _ready() -> void:
	%Fade.position.x = get_right_position()


func fade_out_change_scene(data: TransitionDataOut) -> void:
	assert(data, "No transition data defined")
	
	# set gradient color
	if data.color:
		%Fade.texture.gradient.set_color(1, Color(data.color, 1.0))
		%Fade.texture.gradient.set_color(2, Color(data.color, 1.0))
	
	%Fade.modulate = Color.TRANSPARENT
	%Fade.show()
	
	# replace screen with dummy
	var viewport_texture := get_viewport().get_texture()
	await RenderingServer.frame_post_draw
	var screenshot = viewport_texture.get_image()
	%FreezeScreen.texture = ImageTexture.create_from_image(screenshot)
	%FreezeScreen.show()
	
	var tween = create_tween()
	
	match data.transition:
		Transition.SLIDE:
			%Fade.position.x = get_right_position()
			%Fade.modulate = Color.WHITE
			
			tween.tween_property(%Fade, "position:x", get_middle_position(), data.duration)
		
		Transition.FADE:
			%Fade.position.x = get_middle_position()
			
			tween.tween_property(%Fade, "modulate", Color.WHITE, data.duration)
	
	get_tree().unload_current_scene()
	
	var new_scene: Node = load(data.scene_path).instantiate()
	
	if tween.is_running():
		await tween.finished
	
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	
	finished.emit()


func fade_in(data: TransitionDataIn = TransitionDataIn.new()) -> void:
	%Fade.show()
	%FreezeScreen.hide()
	
	var tween = create_tween()
	
	match data.transition:
		Transition.SLIDE:
			%Fade.modulate = Color.WHITE
			%Fade.position.x = get_middle_position()
			
			tween.tween_property(%Fade, "position:x", get_left_position(), data.duration)
		
		Transition.FADE:
			%Fade.modulate = Color.WHITE
			%Fade.position.x = get_middle_position()
			
			tween.tween_property(%Fade, "modulate", Color.TRANSPARENT, data.duration)
	
	if tween.is_running():
		await tween.finished
	
	%Fade.hide()
	
	finished.emit()


func get_right_position() -> float:
	return get_viewport().get_visible_rect().size.x + MARGIN

func get_middle_position() -> float:
	return - %Fade.size.x * 0.2

func get_left_position() -> float:
	return - %Fade.size.x - MARGIN
