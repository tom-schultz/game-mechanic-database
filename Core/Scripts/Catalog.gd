extends Node

@export var name_control : LineEdit
@export var categories_control : ItemList
@export var tags_control : ItemList
@export var implementations_control : ItemList
@export var related_mechanics_control : ItemList
@export var output_grid : GridContainer
@export var _mechanic_click_sfx : AudioStream
@export var _mechanic_click_volume : float = 0.7

@onready var db : LibraryDatabase = load("res://Core/Resources/MechanicDatabase.tres")
@onready var catalog_item_scene : PackedScene = load("res://Core/Scenes/catalog_item.tscn")
@onready var tab_container: TabContainer = find_child("TabContainer")

var _selected : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	tab_container.current_tab = 1
	db.build_indices()
	
	categories_control.multi_selected \
			.connect(_on_filters_updated.bind(categories_control))
	tags_control.multi_selected \
			.connect(_on_filters_updated.bind(tags_control))
	implementations_control.multi_selected \
			.connect(_on_filters_updated.bind(implementations_control))
	related_mechanics_control.multi_selected \
			.connect(_on_filters_updated.bind(related_mechanics_control))
	
	_selected[categories_control.name] = []
	_selected[tags_control.name] = []
	_selected[implementations_control.name] = []
	_selected[related_mechanics_control.name] = []
	
	for item in db.categories:
		categories_control.add_item(item)
	
	if db.categories.size() == 0:
		categories_control.hide()
	
	for item in db.tags:
		tags_control.add_item(item)
	
	if db.tags.size() == 0:
		tags_control.hide()
	
	for item in db.implementations:
		implementations_control.add_item(item)
	
	if db.implementations.size() == 0:
		implementations_control.hide()
	
	for item in db.related_mechanics:
		related_mechanics_control.add_item(item)
	
	if db.related_mechanics.size() == 0:
		related_mechanics_control.hide()

	_build_results()

func _on_filters_updated(index : int, _unused : bool, control : ItemList):
	AudioPlayer.play_button_press_sfx()
	var multi = Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CTRL)

	if not multi and _selected[control.name].has(index) and _selected[control.name].size() == 1:
		control.deselect(index)

	_selected[control.name] = control.get_selected_items()
	_build_results()

func _build_results():
	var cat_filters = _get_selected_items(categories_control)
	var tag_filters = _get_selected_items(tags_control)
	var game_filters = _get_selected_items(implementations_control)
	var mech_filters = _get_selected_items(related_mechanics_control)
	
	var matched = db.mechanics.filter(func(mechanic):
		var cat = mechanic["Category"]
		var tags = mechanic["Tags"]
		var games = mechanic["Implementations"]
		var mechs = mechanic["Related Mechanics"]
		
		var category_match = (cat_filters.size() == 0
			|| cat_filters.has(cat))
		
		var name_match = (name_control.text.is_empty()
			|| mechanic["Id"].contains(name_control.text))
		
		var tag_match = (tag_filters.size() == 0
			|| tags.any(func(mechanic_item): return tag_filters.has(mechanic_item)))
		
		var implementations_match = (game_filters.size() == 0
			|| games.any(func(mechanic_item): return game_filters.has(mechanic_item)))
		
		var related_mechanics_match = (mech_filters.size() == 0
			|| mechs.any(func(mechanic_item): return mech_filters.has(mechanic_item)))
			
			
		return (category_match
			&& tag_match
			&& implementations_match
			&& related_mechanics_match
			&& name_match)
	)
	
	for label in output_grid.get_children():
		output_grid.remove_child(label)
		label.queue_free()
	
	for mechanic in matched:
		var btn : Button = catalog_item_scene.instantiate()
		btn.text = mechanic["Id"]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_mechanic_pressed.bind(mechanic["Scene"]))
		btn.icon = mechanic["Thumbnail"]
		output_grid.add_child(btn)

func _get_selected_items(list : ItemList):
	var indices = list.get_selected_items()
	var selected = []
	
	for index in indices:
		selected.append(list.get_item_text(index))
	
	return selected

func _on_mechanic_pressed(scene : String):
	AudioPlayer.play_sfx(_mechanic_click_sfx, _mechanic_click_volume)
	if get_tree().change_scene_to_file(scene) != OK:
		print_debug("Could not load scene %" % scene)

func _on_reset_button_pressed():
	AudioPlayer.play_button_press_sfx()
	get_tree().reload_current_scene()

func _on_tab_container_tab_clicked(_tab):
	AudioPlayer.play_tab_click_sfx()
