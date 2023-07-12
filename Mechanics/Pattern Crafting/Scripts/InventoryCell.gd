extends TextureRect
class_name InventoryCell

signal item_updated(cell_type : CellType)

enum CellType { INPUT, OUTPUT, INVENTORY }

@export var cell_type : CellType = CellType.INVENTORY

var item : InventoryItem :
	get: return item
	set(value):
		item_display.texture = null if value == null else value.texture
		item = value
	
var item_display : TextureRect

func _ready():
	item_display = find_child("Item Display")

func _unhandled_input(event: InputEvent):
	var is_press_inside = event is InputEventMouseButton and event.is_pressed() and get_global_rect().has_point(event.position)
	
	if (!is_press_inside || PatternCrafting.I.cursor_item == item):
		return
	
	var temp = PatternCrafting.I.cursor_item
	PatternCrafting.I.set_cursor_item(item, self)
	item = temp
	item_updated.emit(cell_type)
