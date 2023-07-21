extends Node

const VOLUME_MIN = -40

@export var _button_press_sfx : AudioStream
@export_range(0,1) var _button_press_volume : float = 1
@export var _tab_click_sfx : AudioStream
@export_range(0,1) var _tab_click_volume : float = 1

@onready var _music_blue : AudioStreamPlayer = get_node("Music Player Blue")
@onready var _sfx_player : AudioStreamPlayer = get_node("SFX Player")

var _music_volume : float = 0
var _sfx_volume : float = 0

func set_music_volume(volume : float):
	var remapped = remap(volume, 0, 100, VOLUME_MIN, 0)
	_music_volume = remapped
	_music_blue.volume_db = remapped

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
