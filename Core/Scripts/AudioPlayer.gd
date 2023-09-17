extends Node

const VOLUME_MIN = -40
const playlist_prefix = "res://Shared/Audio/Music"

@export var _button_press_sfx : AudioStream
@export_range(0,1) var _button_press_volume : float = 1
@export var _tab_click_sfx : AudioStream
@export_range(0,1) var _tab_click_volume : float = 1
@export var playlists : Dictionary

@onready var _music_player : AudioStreamPlayer = get_node("Music Player")
@onready var _sfx_player : AudioStreamPlayer = get_node("SFX Player")

var _music_volume : float = 0
var _sfx_volume : float = 0
var _track_index : int = 0
var _tracks

func set_playlist(playlist_name : String):
	_tracks = playlists[playlist_name]
	_track_index = 0
	_play_current_track()
	
func get_playlists():
	return playlists.keys()

func set_music_volume(volume : float):
	var remapped = remap(volume, 0, 100, VOLUME_MIN, 0)
	_music_volume = remapped
	_music_player.volume_db = remapped

func set_sfx_volume(volume : float):
	var remapped = remap(volume, 0, 100, VOLUME_MIN, 0)
	_sfx_volume = remapped

func play_button_press_sfx():
	play_sfx(_button_press_sfx, _button_press_volume)
	
func play_tab_click_sfx():
	play_sfx(_tab_click_sfx, _tab_click_volume)

func play_sfx(stream : AudioStream, volume_scale : float = 1):
	_sfx_player.volume_db = _sfx_volume + (1 - volume_scale) * VOLUME_MIN
	_sfx_player.stream = stream
	_sfx_player.play()
	
func change_track(delta : int):
	_track_index = wrapi(_track_index + delta, 0, _tracks.size())
	_play_current_track()

func _play_current_track():
	_music_player.stream = _tracks[_track_index]
	_music_player.play()

func _on_music_player_finished():
	change_track(1)

func track_name():
	var filename = _tracks[_track_index].resource_path.get_file()
	var ext = filename.get_extension()
	return filename.replace("." + ext, "")
