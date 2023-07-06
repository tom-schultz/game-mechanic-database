extends CanvasLayer

@export var description_label: Label
@export var controls_container: Container
@export var config_container: Container
@onready var tab_container: TabContainer = get_node("TabContainer")

func _ready():
	tab_container.current_tab = 1

func get_config_container():
	return config_container

func set_description(text):
	description_label.text = text

func set_controls(controls):
	var node = controls.instantiate()
	controls_container.add_child(node)

func reset_mechanic():
	get_tree().reload_current_scene()

func _unhandled_key_input(event):
	if event.keycode != KEY_ESCAPE:
		return
	
	if OS.has_feature('web'):
		JavaScriptBridge.eval("""
			window.history.back()
		""")
	else:
		get_tree().quit()
