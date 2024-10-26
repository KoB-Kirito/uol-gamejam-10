extends AudioStreamPlayer


const SILENCE = -60.0


## Fades out old song, fades in new song
func fade_to(new_stream: AudioStream, volume: float, duration: float) -> void:
	var tween = create_tween()
	
	if playing:
		if duration > 0:
			tween.tween_property(self, "volume_db", SILENCE, duration / 2)
		tween.tween_callback(func(): stop())
	
	tween.tween_callback(func(): volume_db = SILENCE)
	tween.tween_callback(func(): stream = new_stream)
	tween.tween_callback(func(): play())
	
	if duration > 0:
		tween.tween_property(self, "volume_db", volume, duration / 2)
	else:
		tween.tween_callback(func(): volume_db = volume)


## Fades out current song and stops
func fade_out(duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "volume_db", SILENCE, duration / 2)
	tween.tween_callback(func(): stop())
