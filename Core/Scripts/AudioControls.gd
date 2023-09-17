extends GridContainer

const MUSIC_VOL_DB_KEY = "MUSIC_VOLUME"
const SFX_VOL_DB_KEY = "SFX_VOLUME"

@export var playlist_label : Label
@export var track_label : Label

@onready var _music_slider : HSlider = find_child("Music Volume Slider")
@onready var _sfx_slider : HSlider = find_child("SFX Volume Slider")

var _playlists : Array
var _playlist_index = 0

func _ready():
	if LocalDb.has_key(MUSIC_VOL_DB_KEY):
		var vol = LocalDb.read_key(MUSIC_VOL_DB_KEY)
		AudioPlayer.set_music_volume(vol)
		_music_slider.set_value_no_signal(vol)
		
	if LocalDb.has_key(SFX_VOL_DB_KEY):
		var vol = LocalDb.read_key(SFX_VOL_DB_KEY)
		AudioPlayer.set_sfx_volume(vol)
		_sfx_slider.set_value_no_signal(vol)
	
	_playlists = AudioPlayer.get_playlists()
	_update_playlist()

func _on_music_volume_slider_value_changed(value):
	LocalDb.write_key(MUSIC_VOL_DB_KEY, value)
	AudioPlayer.set_music_volume(value)

func _on_sfx_volume_slider_value_changed(value):
	LocalDb.write_key(SFX_VOL_DB_KEY, value)
	AudioPlayer.set_sfx_volume(value)

func _on_button_pressed():
	AudioPlayer.play_button_press_sfx()

func _on_previous_playlist_pressed():
	_playlist_index = wrapi(_playlist_index + 1, 0, _playlists.size())
	_update_playlist()

func _on_next_playlist_pressed():
	_playlist_index = wrapi(_playlist_index - 1, 0, _playlists.size())
	_update_playlist()

func _update_playlist():
	playlist_label.text = _playlists[_playlist_index]
	AudioPlayer.set_playlist(_playlists[_playlist_index])
	track_label.text = AudioPlayer.track_name()

func _on_previous_track_pressed():
	AudioPlayer.change_track(-1)
	track_label.text = AudioPlayer.track_name()

func _on_next_track_pressed():
	AudioPlayer.change_track(1)
	track_label.text = AudioPlayer.track_name()
