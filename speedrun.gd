extends CanvasLayer
## Speedrun Logic


var completed_once: bool = false
var start_time: int = 0
var active: bool = false


func _ready() -> void:
	hide()


func start() -> void:
	start_time = Time.get_ticks_msec()
	if completed_once:
		show()
	active = true


## Return the elapsed time as string
func stop() -> String:
	active = false
	completed_once = true
	hide()
	return seconds2hhmmss((Time.get_ticks_msec() - start_time) / 1000.0)


func cheated() -> void:
	start_time -= 60000


func _process(delta: float) -> void:
	if not active:
		return
	
	%Label.text = seconds2hhmmss((Time.get_ticks_msec() - start_time) / 1000.0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("speedrun"):
		if visible:
			hide()
			
		else:
			show()


func seconds2hhmmss(total_seconds: float) -> String:
	var seconds:float = fmod(total_seconds , 60.0)
	var minutes:int   =  int(total_seconds / 60.0) % 60
	var hours:  int   =  int(total_seconds / 3600.0)
	var hhmmss_string:String = "%02d:%02d:%05.2f" % [hours, minutes, seconds]
	return hhmmss_string
