extends Node
class_name PatternCrafting

@export var config : MechanicConfig
var output_cell : InventoryCell
var input_cells : Array
var inventory_cells : Array
var _recipes : Array
var _recipe_met : bool

var cursor_item : InventoryItem
var cursor_item_owner : InventoryCell
@onready var cursor_item_display : TextureRect = get_node("Cursor Item")
var mouse_pos

static var I : PatternCrafting = null

func set_cursor_item(item : InventoryItem, original_owner : InventoryCell):
	cursor_item = item
	cursor_item_owner = original_owner
	cursor_item_display.texture = item.texture if item != null else null
	cursor_item_display.global_position = mouse_pos
	cursor_item_display.visible = item != null

# Called when the node enters the scene tree for the first time.
func _ready():
	I = self
	var trimmed = config.recipes.trim_prefix("\n").trim_suffix("\n")
	
	for recipe in trimmed.split("\n"):
		_recipes.append(Recipe.new(recipe))
	
	output_cell = find_child("Output Inventory Cell")
	output_cell.item_updated.connect(_on_item_updated)

	input_cells = find_children("Input Inventory Cell*")

	for input_cell in input_cells:
		input_cell.item_updated.connect(_on_item_updated)

	input_cells[0].item = InventoryItem.new("flour")
	input_cells[1].item = InventoryItem.new("flour")
	input_cells[2].item = InventoryItem.new("flour")
	input_cells[3].item = InventoryItem.new("water")
	input_cells[5].item = InventoryItem.new("salt")
	_on_item_updated(InventoryCell.CellType.INPUT)
	
	inventory_cells = find_children("Inventory Cell*")
	inventory_cells[0].item = InventoryItem.new("egg")
	inventory_cells[1].item = InventoryItem.new("egg")
	inventory_cells[2].item = InventoryItem.new("egg")
	inventory_cells[3].item = InventoryItem.new("egg")
	inventory_cells[4].item = InventoryItem.new("egg")
	inventory_cells[5].item = InventoryItem.new("butter")
	inventory_cells[6].item = InventoryItem.new("butter")
	inventory_cells[7].item = InventoryItem.new("cheese")
	inventory_cells[8].item = InventoryItem.new("cheese")
	inventory_cells[9].item = InventoryItem.new("cheese")
	
	inventory_cells[10].item = InventoryItem.new("black_pepper")
	inventory_cells[11].item = InventoryItem.new("salt")
	inventory_cells[12].item = InventoryItem.new("salt")
	inventory_cells[13].item = InventoryItem.new("salt")
	inventory_cells[14].item = InventoryItem.new("spinach")
	inventory_cells[15].item = InventoryItem.new("tomato")
	inventory_cells[16].item = InventoryItem.new("onion")
	inventory_cells[17].item = InventoryItem.new("water")
	inventory_cells[18].item = InventoryItem.new("water")
	inventory_cells[19].item = InventoryItem.new("water")
	
	inventory_cells[20].item = InventoryItem.new("wheat")
	inventory_cells[21].item = InventoryItem.new("wheat")
	inventory_cells[22].item = InventoryItem.new("wheat")
	inventory_cells[23].item = InventoryItem.new("wheat")
	inventory_cells[24].item = InventoryItem.new("wheat")
	inventory_cells[25].item = InventoryItem.new("wheat")
	inventory_cells[26].item = InventoryItem.new("wheat")
	
	cursor_item_display.hide()

func _on_item_updated(cell_type : InventoryCell.CellType):
	if (_recipe_met && cell_type == InventoryCell.CellType.OUTPUT && output_cell.item == null):
		_clear_inputs()
		return
		
	if (cell_type == InventoryCell.CellType.INPUT):
		var inputs = _build_inputs()
		
		for recipe in _recipes:
			if (recipe.check_recipe(inputs)):
				_recipe_met = true
				output_cell.item = recipe.output
				return
		
		output_cell.item = null

func _clear_inputs():
	for input in input_cells:
		input.item = null

func _build_inputs():
	var inputs = Array()
	
	for input in input_cells:
		inputs.append(input.item.id if input.item != null else "")
	
	return inputs

func _input(event):
	if event is InputEventMouseMotion:
		mouse_pos = event.position
		cursor_item_display.position = mouse_pos
