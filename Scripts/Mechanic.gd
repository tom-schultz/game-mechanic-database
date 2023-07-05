extends Node
class_name Mechanic

@export var config_container : Container

func build_config_list():
	var properties = get_property_list()
	var config_array = []
	
	for property in get_property_list():
		if (!property["name"].begins_with("cfg_")):
			continue
			
		var prop_name = property["name"].substr(4)
		
		config_array.append({
			config_key = prop_name,
			human_name = _human_readable_name(prop_name),
			type = property["type"],
			value = get(property["name"])
		})
	
	return config_array

func _build_config_ui():
	var config_list = build_config_list()
	
	for config_item in config_list:
		_build_label(config_item)
		_build_spin_box(config_item)
	
func _human_readable_name(property_name:String):
	var tokens = property_name.split("_")
	var name = ""
	
	for token in tokens:
		token = token.capitalize()
		name += token + " "
	
	return name.trim_suffix(" ")

func _build_label(config_item):
		var label = Label.new()
		label.name = config_item.config_key
		label.text = config_item.human_name
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		config_container.add_child(label)

func _build_spin_box(config_item):
		var spin_box = SpinBox.new()
		spin_box.name = config_item.config_key
		spin_box.value = config_item.value
		spin_box.update_on_text_changed = true
		spin_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		config_container.add_child(spin_box)
