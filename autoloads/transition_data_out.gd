class_name TransitionDataOut
extends Resource


@export_file("*.tscn") var scene_path: String

@export_enum("Side", "Fade") var transition: int = SceneTransition.Transition.FADE
@export_color_no_alpha var color: Color = Color.BLACK
@export var duration: float = 1.0
