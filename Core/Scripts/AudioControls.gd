extends GridContainer

func _on_volume_slider_value_changed(value):
	MusicPlayer.set_volume(value)
