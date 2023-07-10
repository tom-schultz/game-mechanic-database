@tool
extends EditorPlugin

var mechanic_scene : PackedScene
var mechanic_controls_scene : PackedScene
var mechanic_script : Script
var mechanic_config_script : Script
const base_dir = "res://Mechanics/"
const description_templ : String = "res://addons/tmml_manager/Template/description.txt"
var mechanic_name = "Inventory Pattern Crafting"
var mechanic_category = "Minor Mechanic"
var mechanic_path
var scene_path
var scripts_path
var textures_path
var audio_path
var editor_interface: EditorInterface
var editor_file_system : EditorFileSystem
var tmml

func _enter_tree():
	mechanic_script = load("res://addons/tmml_manager/Template/Scripts/MECHANIC.gd")
	mechanic_config_script = load("res://addons/tmml_manager/Template/Scripts/MECHANIC_CONFIG.gd")
	mechanic_scene = load("res://addons/tmml_manager/Template/Scenes/MECHANIC.tscn")
	mechanic_controls_scene = load("res://addons/tmml_manager/Template/Scenes/MECHANIC_CONTROLS.tscn")
	editor_interface = get_editor_interface()
	editor_file_system = editor_interface.get_resource_filesystem()
	_build_plugin_ui()

func _build_plugin_ui():
	tmml = load("res://addons/tmml_manager/tmml_manager.tscn").instantiate()
	tmml.get_node("Submit").pressed.connect(build_new_mechanic)
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, tmml)

func build_new_mechanic():
	mechanic_name = tmml.get_node("Mechanic Name").text
	mechanic_category = tmml.get_node("Mechanic Category").text
	mechanic_path = base_dir + mechanic_name + "/"
	scene_path = mechanic_path + "Scenes/"
	scripts_path = mechanic_path + "Scripts/"
	textures_path = mechanic_path + "Textures/"
	audio_path = mechanic_path + "Audio/"
	
	if (DirAccess.dir_exists_absolute(mechanic_path)):
		print_debug("Mechanic path already exists: " + mechanic_path)
		OS.move_to_trash(ProjectSettings.globalize_path(mechanic_path))
#		return
		
	DirAccess.make_dir_absolute(mechanic_path.trim_suffix("/"))
	DirAccess.make_dir_absolute(scene_path.trim_suffix("/"))
	DirAccess.make_dir_absolute(scripts_path.trim_suffix("/"))
	DirAccess.make_dir_absolute(textures_path.trim_suffix("/"))
	DirAccess.make_dir_absolute(audio_path.trim_suffix("/"))
	
	var scene_file_path = _build_mechanic_scene()
	editor_file_system.scan_sources()

func _build_mechanic_scene():
	var pascal = mechanic_name.to_pascal_case()
	var snake = mechanic_name.to_snake_case()
	
	var new_mechanic_script = _render_script_templ(
		mechanic_script,
		pascal)
	
	var new_config_script = _render_script_templ(
		mechanic_config_script,
		pascal + "Config")
	
	var controls_scene = _copy_scene(mechanic_controls_scene,
		mechanic_name + " Controls",
		scene_path + snake + "_controls.tscn")
		
	var mechanic : Node = mechanic_scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	mechanic.name = mechanic_name
	mechanic.set_script(new_mechanic_script)
	var config = mechanic.get_node("Config")
	var library = config.library_ui
	library.mechanic_controls_scene = controls_scene
	library.mechanic_description_file = _copy_description_file(mechanic_path)
	library.mechanic_name = mechanic_name
	library.mechanic_category = mechanic_category
	config.set_script(new_config_script)
	config.library_ui = library
	mechanic.config = config
	
	var new_pack = PackedScene.new()
	new_pack.resource_name = mechanic_name
	var scene_file_path = scene_path + snake + ".tscn"
	
	if (new_pack.pack(mechanic) == OK):
		ResourceSaver.save(new_pack, scene_file_path)
	
	editor_interface.set_main_screen_editor("2D")
	editor_interface.open_scene_from_path(scene_file_path)

func _render_script_templ(script : Script, script_name : String):
	var new_path = scripts_path + script_name + ".gd"
	var new_script_file = FileAccess.open(new_path, FileAccess.WRITE)
	var new_source = script.source_code.replace("CLASS_NAME", script_name)
	new_script_file.store_string(new_source)
	new_script_file.close()
	var new_script : Script = load(new_path)
	return new_script
	
func _copy_description_file(mechanic_path):
	var desc_path = mechanic_path + "description.txt"
	DirAccess.copy_absolute(description_templ, mechanic_path + "description.txt")
	return desc_path

func _copy_scene(packed_scene, new_name, path):
	var scene = packed_scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	scene.name = new_name
	var new_pack = PackedScene.new()
	new_pack.resource_name = new_name
	
	if (new_pack.pack(scene) == OK):
		ResourceSaver.save(new_pack, path)
		
	return load(path)
	
func _exit_tree():
	remove_control_from_docks(tmml)
	tmml.free()
