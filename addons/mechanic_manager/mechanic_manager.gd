@tool
extends EditorPlugin

var mechanic_scene : PackedScene
var mechanic_controls_scene : PackedScene
var mechanic_script : Script
var mechanic_config_script : Script
const base_dir = "res://Mechanics/"
const description_templ : String = "res://addons/mechanic_manager/Template/description.txt"
const attributions_templ : String = "res://addons/mechanic_manager/Template/attributions.txt"
var mechanic_name : String = "Inventory Pattern Crafting"
var mechanic_category : String = "Minor Mechanic"
var mechanic_path : String
var scene_path : String
var scripts_path : String
var editor_interface: EditorInterface
var editor_file_system : EditorFileSystem
var mechanic_manager : Control

func _enter_tree():
	mechanic_script = load("res://addons/mechanic_manager/Template/Scripts/MECHANIC.gd")
	mechanic_config_script = load("res://addons/mechanic_manager/Template/Scripts/MECHANIC_CONFIG.gd")
	mechanic_scene = load("res://addons/mechanic_manager/Template/Scenes/MECHANIC.tscn")
	mechanic_controls_scene = load("res://addons/mechanic_manager/Template/Scenes/MECHANIC_CONTROLS.tscn")
	editor_interface = get_editor_interface()
	editor_file_system = editor_interface.get_resource_filesystem()
	
	mechanic_manager = load("res://addons/mechanic_manager/mechanic_manager.tscn").instantiate()
	mechanic_manager.get_node("Submit").pressed.connect(build_new_mechanic)
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, mechanic_manager)

func build_new_mechanic():
	var name_control = mechanic_manager.get_node("Mechanic Name")
	mechanic_name = name_control.text
	name_control.text = ""
	
	var category_control = mechanic_manager.get_node("Mechanic Category")
	mechanic_category = category_control.text
	category_control.text = ""
	
	mechanic_path = base_dir + mechanic_name + "/"
	scene_path = mechanic_path + "Scenes/"
	scripts_path = mechanic_path + "Scripts/"
	
	if (DirAccess.dir_exists_absolute(mechanic_path)):
		print_debug("Mechanic path already exists: " + mechanic_path)
		OS.move_to_trash(ProjectSettings.globalize_path(mechanic_path))
#		return
		
	DirAccess.make_dir_absolute(mechanic_path.trim_suffix("/"))
	DirAccess.make_dir_absolute(scene_path.trim_suffix("/"))
	DirAccess.make_dir_absolute(scripts_path.trim_suffix("/"))
	
	var scene_file_path = _build_mechanic_scene()
	_copy_file(attributions_templ, mechanic_path, "attributions.txt")
	editor_file_system.scan_sources()

func _build_mechanic_scene():
	var pascal = mechanic_name.to_pascal_case()
	var snake = mechanic_name.to_snake_case()
	var config_class = pascal + "Config"
	
	var new_config_script = _render_script_templ(
		mechanic_config_script,
		pascal + "Config",
		{ "CONFIG_CLASS": config_class })
	
	var new_mechanic_script = _render_script_templ(
		mechanic_script,
		pascal,
		{ "MECHANIC_CLASS": pascal, "CONFIG_CLASS": config_class })
	
	var controls_scene = _copy_scene(mechanic_controls_scene,
		mechanic_name + " Controls",
		scene_path + snake + "_controls.tscn")
		
	var mechanic : Node = mechanic_scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	mechanic.name = mechanic_name
	mechanic.set_script(new_mechanic_script)
	
	var config_res = Resource.new()
	config_res.set_script(new_config_script)
	ResourceSaver.save(config_res, mechanic_path + mechanic_name + " Config.tres")
	mechanic.config = config_res
	var library = mechanic.get_node("Core UI")
	library.mechanic_config = config_res
	
	library.mechanic_controls_scene = controls_scene
	library.mechanic_description_file = _copy_file(description_templ, mechanic_path, "description.txt")
	library.mechanic_name = mechanic_name
	library.mechanic_category = mechanic_category
	
	var new_pack = PackedScene.new()
	new_pack.resource_name = mechanic_name
	var scene_file_path = scene_path + snake + ".tscn"
	
	if (new_pack.pack(mechanic) == OK):
		ResourceSaver.save(new_pack, scene_file_path)
	
	editor_interface.set_main_screen_editor("2D")
	editor_interface.open_scene_from_path(scene_file_path)

func _render_script_templ(script : Script, script_name : String, replace_symbols : Dictionary):
	var new_path = scripts_path + script_name + ".gd"
	var new_script_file = FileAccess.open(new_path, FileAccess.WRITE)
	var new_source = script.source_code
	
	for symbol in replace_symbols:
		new_source = new_source.replace(symbol, replace_symbols[symbol])
		
	new_script_file.store_string(new_source)
	new_script_file.close()
	editor_file_system.update_file(new_path)
	var new_script : Script = load(new_path)
	
	return new_script
	
func _copy_file(template_path, mechanic_path : String, filename : String):
	var file_path = mechanic_path + filename
	DirAccess.copy_absolute(template_path, mechanic_path + filename)
	return file_path

func _copy_scene(packed_scene, new_name, path):
	var scene = packed_scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	scene.name = new_name
	var new_pack = PackedScene.new()
	new_pack.resource_name = new_name
	
	if (new_pack.pack(scene) == OK):
		ResourceSaver.save(new_pack, path)
		
	return load(path)
	
func _exit_tree():
	remove_control_from_docks(mechanic_manager)
	mechanic_manager.free()
