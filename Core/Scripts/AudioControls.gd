extends GridContainer

const MUSIC_VOL_DB_KEY = "MUSIC_VOLUME"
const SFX_VOL_DB_KEY = "SFX_VOLUME"

@onready var _music_slider : HSlider = find_child("Music Volume Slider")
@onready var _sfx_slider : HSlider = find_child("SFX Volume Slider")

func _ready():
	if LocalDb.has_key(MUSIC_VOL_DB_KEY):
		var vol = LocalDb.read_key(MUSIC_VOL_DB_KEY)
		AudioPlayer.set_music_volume(vol)
		_music_slider.set_value_no_signal(vol)
		
	if LocalDb.has_key(SFX_VOL_DB_KEY):
		var vol = LocalDb.read_key(SFX_VOL_DB_KEY)
		AudioPlayer.set_sfx_volume(vol)
		_sfx_slider.set_value_no_signal(vol)

func _on_music_volume_slider_value_changed(value):
	LocalDb.write_key(MUSIC_VOL_DB_KEY, value)
	AudioPlayer.set_music_volume(value)

func _on_sfx_volume_slider_value_changed(value):
	LocalDb.write_key(SFX_VOL_DB_KEY, value)
	AudioPlayer.set_sfx_volume(value)

func _on_button_pressed():
	AudioPlayer.play_button_press_sfx()
