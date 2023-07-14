extends Node

var db : LibraryDatabase

@export var name_control : LineEdit
@export var categories_control : ItemList
@export var tags_control : ItemList
@export var related_games_control : ItemList
@export var related_mechanics_control : ItemList
@export var output_grid : GridContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	db = load("res://Core/Resources/LibraryDatabase.tres")
	db.build_indices()
	
	for item in db.categories:
		categories_control.add_item(item)
	
	for item in db.tags:
		tags_control.add_item(item)
	
	for item in db.related_games:
		related_games_control.add_item(item)
	
	for item in db.related_mechanics:
		related_mechanics_control.add_item(item)

func _on_filters_updated():
	var cat_filters = _get_selected_items(categories_control)
	var tag_filters = _get_selected_items(tags_control)
	var game_filters = _get_selected_items(related_games_control)
	var mech_filters = _get_selected_items(related_mechanics_control)
	
	var matched = db.mechanics.filter(func(mechanic):
		var cat = mechanic["Category"]
		var tags = mechanic["Tags"]
		var games = mechanic["Related Games"]
		var mechs = mechanic["Related Mechanics"]
		
		var category_match = (cat_filters.size() == 0
			|| cat_filters.has(cat))
		
		var name_match = (name_control.text.is_empty()
			|| mechanic["Id"].contains(name_control.text))
		
		var tag_match = (tag_filters.size() == 0
			|| tags.any(func(mechanic_item): return tag_filters.has(mechanic_item)))
		
		var related_games_match = (game_filters.size() == 0
			|| games.any(func(mechanic_item): return game_filters.has(mechanic_item)))
		
		var related_mechanics_match = (mech_filters.size() == 0
			|| mechs.any(func(mechanic_item): return mech_filters.has(mechanic_item)))
			
			
		return (category_match
			&& tag_match
			&& related_games_match
			&& related_mechanics_match
			&& name_match)
	)
	
	print_debug(matched)
	
	for label in output_grid.get_children():
		output_grid.remove_child(label)
		label.queue_free()
	
	for mechanic in matched:
		var label = Label.new()
		label.text = mechanic["Id"]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_color_override("font_color", Color.BLACK)
		output_grid.add_child(label)

func _get_selected_items(list : ItemList):
	var indices = list.get_selected_items()
	var selected = []
	
	for index in indices:
		selected.append(list.get_item_text(index))
	
	return selected
