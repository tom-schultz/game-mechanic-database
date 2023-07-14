extends Node2D
class_name MechanicLibraryUI

@export var mechanic_name: String
@export var mechanic_category: String
@export var description_label: Label
@export var mechanic_description_file: String
@export var controls_container: Container
@export var mechanic_controls_scene: PackedScene
@export var config_container: Container
@onready var tab_container: TabContainer = find_child("TabContainer")

func _ready():
	tab_container.current_tab = 1
	var controls_node = mechanic_controls_scene.instantiate()
	controls_container.add_child(controls_node)

	var file = FileAccess.open(mechanic_description_file, FileAccess.READ)
	description_label.text = file.get_as_text()
	var title : Label = find_child("Title")
	title.text = mechanic_name
	var category : Label = find_child("Category")
	category.text = mechanic_category

func get_config_container():
	return config_container

func reset_mechanic():
	get_tree().reload_current_scene()

func _unhandled_key_input(event):
	if event.keycode == KEY_ESCAPE:
		_do_exit()


func _on_exit_button_pressed():
	_do_exit()

func _do_exit():
	if OS.has_feature('web'):
		JavaScriptBridge.eval("""
			window.history.back()
		""")
	else:
		get_tree().quit()
