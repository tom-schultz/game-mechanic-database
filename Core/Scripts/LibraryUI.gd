extends CanvasLayer

@export var config_container: Container
@export var description_label: Label

func get_config_container():
	return config_container

func set_description(text):
	description_label.text = text
