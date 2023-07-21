extends TextureRect
class_name InventoryCell

signal item_updated(cell_type : CellType)

enum CellType { INPUT, OUTPUT, INVENTORY }

@export var cell_type : CellType = CellType.INVENTORY
@export var item_pickup_sfx : AudioStream
@export_range(0,1) var item_pickup_sfx_volume : float = 1

var item : InventoryItem :
	get: return item
	set(value):
		item_display.texture = null if value == null else value.texture
		item_display.tooltip_text = "" if value == null else value.id.capitalize()
		item = value

var item_display : TextureRect

func _ready():
	item_display = find_child("Item Display")

func _unhandled_input(event: InputEvent):
	var is_press_inside = event is InputEventMouseButton and event.is_pressed() and get_global_rect().has_point(event.position)

	if (!is_press_inside
			|| PatternCrafting.I.cursor_item == item
			|| (cell_type == CellType.OUTPUT and PatternCrafting.I.cursor_item != null)):
		return
	
	var temp = PatternCrafting.I.cursor_item
	AudioPlayer.play_sfx(item_pickup_sfx, item_pickup_sfx_volume)
	PatternCrafting.I.set_cursor_item(item, self)
	item = temp
	item_updated.emit(cell_type)
