class_name InventoryItem

var id : String = "error"
var texture : Texture

func _init(item_id : String):
	self.id = item_id
	texture = load("res://Shared/Textures/Items/" + item_id + ".svg")
