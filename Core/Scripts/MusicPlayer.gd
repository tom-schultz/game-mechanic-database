extends Node

@onready var _music_blue : AudioStreamPlayer = get_node("Music Player Blue")

func set_volume(volume : float):
	_music_blue.volume_db = remap(volume, 0, 100, -60, 0)
