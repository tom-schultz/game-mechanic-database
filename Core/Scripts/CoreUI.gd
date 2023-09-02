extends Node2D
class_name MechanicLibraryUI

@export var mechanic_name: String
@export var mechanic_category: String
@export var mechanic_config : Resource
@export var description_label: RichTextLabel
@export var mechanic_description_file: String
@export var controls_container: Container
@export var mechanic_controls_scene: PackedScene
@export var tab_container: TabContainer = find_child("TabContainer")
@export var catalog_scene: PackedScene
@export var grid : GridContainer
@export var config_editor : Panel
@onready var theme : Theme = load("res://Shared/main_theme.tres")

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
	
	var cancel_btn = config_editor.find_child("Cancel Button")
	cancel_btn.pressed.connect(_close_config_editor)
	
	_build_config_ui()

func _build_config_ui():
	var config_list = _build_config_list()
	
	for config_item in config_list:
		match (typeof(config_item.value)):
			TYPE_DICTIONARY:
				_build_dict(config_item.config_key, config_item.human_name, config_item.value)
			TYPE_ARRAY:
				_build_array(config_item.config_key, config_item.human_name, config_item.value)
			TYPE_FLOAT,TYPE_INT:
				_build_label(config_item.human_name)
				_build_spin_box(config_item.config_key, config_item.value)
			TYPE_STRING:
				if(config_item.is_multiline):
					_build_label(config_item.human_name)
					_build_config_editor_button(config_item.config_key)
				else:
					_build_label(config_item.human_name)
					_build_text_box(config_item.config_key, config_item.value)

func _build_config_list():	
	var config_script = mechanic_config.get_script()
	var script_props = config_script.get_script_property_list()
	var script_filename = config_script.resource_path.split("/")[-1]
	
	var config_array = []
	
	for property in script_props:
		if (property["usage"] & PROPERTY_USAGE_EDITOR != PROPERTY_USAGE_EDITOR
				or property["name"] == script_filename):
			continue
			
		var prop_name = property["name"]
		
		config_array.append({
			config_key = prop_name,
			human_name = _human_readable_name(prop_name),
			value = mechanic_config.get(property["name"]),
			is_multiline = property["hint"] == PROPERTY_HINT_MULTILINE_TEXT
		})
	
	return config_array
	
func _human_readable_name(property_name:String):
	var tokens = property_name.split("_")
	var human_name = ""
	
	for token in tokens:
		token = token.capitalize()
		human_name += token + " "
	
	return human_name.trim_suffix(" ")

func _build_array(config_key, array_label, array):
	_build_label("")
	_build_label("")
	_build_label(array_label)
	_build_label("")
	
	for i in range(0, array.size()):
		_build_label("%s[%d]" % [array_label, i])
		var key = "%s/%d" % [config_key, i]
		
		match(typeof(array[i])):
			TYPE_FLOAT,TYPE_INT:
				_build_spin_box(key, array[i])
			TYPE_STRING:
				_build_text_box(key, array[i])

func _build_dict(config_key, dict_label, dict):
	_build_label("")
	_build_label("")
	_build_label(dict_label)
	_build_label("")
	
	for key in dict:
		var new_config_key = config_key + "/" + key
		var label = "%s/%s" % [dict_label, key]
		
		match(typeof(dict[key])):
			TYPE_ARRAY:
				_build_array(new_config_key, label,  dict[key])
			TYPE_DICTIONARY:
				_build_dict(new_config_key, label, dict[key])
			TYPE_FLOAT,TYPE_INT:
				_build_label(key)
				_build_spin_box(new_config_key, dict[key])
			TYPE_STRING:
				_build_label(key)
				_build_text_box(new_config_key, dict[key])

func _build_label(label_text):
	var label = Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.theme = theme
	grid.add_child(label)

func _build_spin_box(config_key, value):
	var field = ConfigFieldFloat.new()
	field.custom_arrow_step = 0.1 if typeof(value) == TYPE_FLOAT else 1.0
	field.min_value = -9999999999
	field.max_value = 9999999999
	field.rounded = typeof(value) == TYPE_INT
	field.step = 0.01 if typeof(value) == TYPE_FLOAT else 1.0
	field.update_on_text_changed = true
	field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	field.focus_mode = Control.FOCUS_CLICK
	field.theme = theme
	field.value_changed.connect(_on_value_changed.bind(config_key))
	field.name = config_key
	field.value = value
	grid.add_child(field)

func _build_config_editor_button(config_key : String):
	var btn = Button.new()
	btn.text = "Edit"
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.pressed.connect(_open_config_editor.bind(config_key))
	grid.add_child(btn)

func _open_config_editor(config_key : String):
	var text_area = config_editor.find_child("Text Editor")
	text_area.text = mechanic_config.get(config_key)
	var save_btn = config_editor.find_child("Save Button")
	
	if save_btn.pressed.is_connected(_on_value_changed_text_edit):
		save_btn.pressed.disconnect(_on_value_changed_text_edit)
		
	save_btn.pressed.connect(_on_value_changed_text_edit.bind(text_area, config_key))
	config_editor.visible = true
	
func _close_config_editor():
	config_editor.visible = false

func _build_text_box(config_key, value):
	var field = ConfigFieldShortString.new()
	field.text = value
	field.focus_mode = Control.FOCUS_CLICK
	field.text_changed.connect(_on_value_changed.bind(config_key))
	grid.add_child(field)

func _on_value_changed(value, config_key: String):
	if (config_key.contains("/")):
		var keys = config_key.split("/")
		var curr = mechanic_config.get(keys[0])
		var i = 1
		
		while i < keys.size() - 1:
			if (typeof(curr) == TYPE_DICTIONARY):
				curr = curr[keys[i]]
			else:
				curr = curr[keys[i].to_int()]
			i += 1
		
		if (typeof(curr) == TYPE_DICTIONARY):
			curr[keys[i]] = value
		else:
			curr[keys[i].to_int()] = value
	else:
		mechanic_config.set(config_key, value)

func _on_value_changed_text_edit(text_edit, config_key: String):
	if (config_key.contains("/")):
		var keys = config_key.split("/")
		var curr = mechanic_config.get(keys[0])
		var i = 1
		
		while i < keys.size() - 1:
			curr = curr[keys[i]]
			i += 1
		
		curr[keys[i]] = text_edit.text
	else:
		mechanic_config.set(config_key, text_edit.text)

func _on_return_to_catalog_pressed():
	AudioPlayer.play_button_press_sfx()
	get_tree().change_scene_to_packed(catalog_scene)

func reset_mechanic():
	AudioPlayer.play_button_press_sfx()
	get_tree().reload_current_scene()

func _on_description_text_meta_clicked(meta):
	OS.shell_open(str(meta))

func _on_tab_clicked(_tab):
	AudioPlayer.play_tab_click_sfx()

func _on_save_button_pressed():
	config_editor.visible = false

func _on_cancel_button_pressed():
	config_editor.visible = false
