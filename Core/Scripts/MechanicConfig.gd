extends Node
class_name MechanicConfig

@export var library_ui : MechanicLibraryUI
var config_container : Container
var theme


func build_config_ui():
	config_container = library_ui.get_config_container()
	theme = load("res://Shared/tmml_theme.tres")
	var config_list = _build_config_list()
	
	for config_item in config_list:
		if (typeof(config_item.value) == TYPE_DICTIONARY):
			_build_dict_grid(config_item.config_key, config_item.human_name, config_item.value)
		else:
			_build_label(config_container, config_item.human_name)
			_build_spin_box(config_container, config_item.config_key, config_item.value)

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
			value = get(property["name"])
		})
	
	return config_array
	
func _human_readable_name(property_name:String):
	var tokens = property_name.split("_")
	var human_name = ""
	
	for token in tokens:
		token = token.capitalize()
		human_name += token + " "
	
	return human_name.trim_suffix(" ")

func _build_dict_grid(config_key, dict_label, dict):
	_build_label(config_container, "")
	_build_label(config_container, "")
	_build_label(config_container, dict_label)
	_build_label(config_container, "")
	
	for key in dict:
		var new_config_key = config_key + "/" + key
		
		if (typeof(dict[key]) == TYPE_DICTIONARY):
			_build_dict_grid(new_config_key, dict_label + "/" + key, dict[key])
		else:
			_build_label(config_container, key)
			_build_spin_box(config_container, new_config_key, dict[key])

func _build_label(container, label_text):
		var label = Label.new()
		label.text = label_text
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.theme = theme
		container.add_child(label)

func _build_spin_box(grid, config_key, value):
		var spin_box = ConfigField.new()
		spin_box.custom_arrow_step = 0.1
		spin_box.min_value = -9999999999
		spin_box.max_value = 9999999999
		spin_box.rounded = false
		spin_box.step = 0.01
		spin_box.update_on_text_changed = true
		spin_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		spin_box.focus_mode = Control.FOCUS_CLICK
		spin_box.theme = theme
		spin_box.value_changed.connect(_on_value_changed.bind(config_key))
		spin_box.name = config_key
		spin_box.value = value
		grid.add_child(spin_box)

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
