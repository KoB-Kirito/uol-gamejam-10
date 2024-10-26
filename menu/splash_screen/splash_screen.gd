extends Control


@export var scene_transition: TransitionDataOut


@export_group("Splash Transitions")
@export_subgroup("Fade In")
@export var fade_in_duration: float = 1.0
@export var fade_in_transition: Tween.TransitionType = Tween.TransitionType.TRANS_QUAD
@export var fade_in_ease: Tween.EaseType

@export_subgroup("Stay")
@export var stay_duration: float = 1.0

@export_subgroup("Fade Out")
@export var fade_out_duration: float = 1.2
@export var fade_out_transition: Tween.TransitionType = Tween.TransitionType.TRANS_QUAD
@export var fade_out_ease: Tween.EaseType = Tween.EASE_OUT

var tween: Tween

func _ready() -> void:
	PauseMenu.enabled = false
	
	tween = create_tween()
	
	# godot
	tween.tween_property(%Fade, "modulate", Color.TRANSPARENT, fade_in_duration).set_trans(fade_in_transition).set_ease(fade_in_ease)
	tween.tween_interval(stay_duration)
	tween.tween_property(%Fade, "modulate", Color.WHITE, fade_out_duration).set_trans(fade_out_transition).set_ease(fade_out_ease)
	
	# dialogic
	#tween.tween_property(%LogoFade, "modulate", Color.WHITE, fade_in_duration).set_trans(fade_in_transition).set_ease(fade_in_ease)
	#tween.tween_property(%DialogicSplash, "modulate", Color.WHITE, fade_in_duration).set_trans(fade_in_transition).set_ease(fade_in_ease)
	#tween.tween_interval(stay_duration)
	#tween.tween_property(%Fade, "modulate", Color.WHITE, fade_out_duration).set_trans(fade_out_transition).set_ease(fade_out_ease)
	
	
	#TODO: Team splash, Best played with controller?, ...
	
	
	tween.tween_callback(func(): SceneTransition.fade_out_change_scene(scene_transition))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		tween.stop()
		SceneTransition.fade_out_change_scene(scene_transition)
