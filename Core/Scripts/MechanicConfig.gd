extends Node
class_name MechanicConfig

@export var library_ui : MechanicLibraryUI
var config_container : Container
var theme

func build_config_ui():
	config_container = library_ui.get_config_container()
	var grid : GridContainer = _new_grid()
	theme = load("res://Shared/tmml_theme.tres")
	var config_list = _build_config_list()
	
	for config_item in config_list:			
		match (typeof(config_item.value)):
			TYPE_DICTIONARY:
				_build_dict(grid, config_item.config_key, config_item.human_name, config_item.value)
			TYPE_FLOAT,TYPE_INT:
				_build_label(grid, config_item.human_name)
				_build_spin_box(grid, config_item.config_key, config_item.value)
			TYPE_STRING:
				if(config_item.is_multiline):
					_build_label(config_container, config_item.human_name)
					_build_text_area(config_container, config_item.config_key, config_item.value)
				else:
					_build_label(grid, config_item.human_name)
					_build_text_box(grid, config_item.config_key, config_item.value)

func _new_grid():
	var grid = GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	config_container.add_child(grid)
	return grid

func _build_config_list():	
	var script : Script = get_script()
	var script_props = script.get_script_property_list()
	var base_script : Script = script.get_base_script()
	var base_script_props = base_script.get_script_property_list()
	var script_filename = script.resource_path.split("/")[-1]
	
	for prop in base_script_props:
		script_props.erase(prop)
	
	var config_array = []
	
	for property in script_props:
		if (property["name"] == script_filename):
			continue
			
		var prop_name = property["name"]
		
		config_array.append({
			config_key = prop_name,
			human_name = _human_readable_name(prop_name),
			value = get(property["name"]),
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

func _build_dict(container, config_key, dict_label, dict):
	_build_label(container, "")
	_build_label(container, "")
	_build_label(container, dict_label)
	_build_label(container, "")
	
	for key in dict:
		var new_config_key = config_key + "/" + key
		
		if (typeof(dict[key]) == TYPE_DICTIONARY):
			_build_dict(container, new_config_key, dict_label + "/" + key, dict[key])
		else:
			_build_label(container, key)
			_build_spin_box(container, new_config_key, dict[key])

func _build_label(container, label_text):
		var label = Label.new()
		label.text = label_text
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.theme = theme
		container.add_child(label)

func _build_spin_box(container, config_key, value):
		var field = ConfigFieldFloat.new()
		field.custom_arrow_step = 0.1
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
		container.add_child(field)
		
func _build_text_area(container, config_key, value):
	var field = ConfigFieldLongString.new()
	field.initialize()
	field.text = value
	field.focus_mode = Control.FOCUS_CLICK
	field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	field.size_flags_vertical = Control.SIZE_EXPAND_FILL
	field.scroll_fit_content_height = true
	field.wrap_mode = TextEdit.LINE_WRAPPING_NONE
	field.text_changed.connect(_on_value_changed_text_edit.bind(field, config_key))
	container.add_child(field)

func _build_text_box(container, config_key, value):
	var field = ConfigFieldShortString.new()
	field.text = value
	field.focus_mode = Control.FOCUS_CLICK
	field.text_changed.connect(_on_value_changed.bind(config_key))
	container.add_child(field)

func _on_value_changed(value, config_key: String):
	if (config_key.contains("/")):
		var keys = config_key.split("/")
		var curr = get(keys[0])
		var i = 1
		
		while i < keys.size() - 1:
			curr = curr[keys[i]]
			i += 1
		
		curr[keys[i]] = value
	else:
		set(config_key, value)

func _on_value_changed_text_edit(text_edit, config_key: String):
	if (config_key.contains("/")):
		var keys = config_key.split("/")
		var curr = get(keys[0])
		var i = 1
		
		while i < keys.size() - 1:
			curr = curr[keys[i]]
			i += 1
		
		curr[keys[i]] = text_edit.text
	else:
		set(config_key, text_edit.text)
