extends Resource
class_name LibraryDatabase

var mechanics : Array = [
	{
		"Id": "Bobber Fishing",
		"Category": "Timed Action",
		"Tags": [ "fishing" ],
		"Implementations": [ "World of Warcraft" ],
		"Related Mechanics": [  ],
		"Scene" : "res://Mechanics/Bobber Fishing/Scenes/bobber_fishing.tscn",
		"Thumbnail" : "res://Mechanics/Bobber Fishing/thumbnail.png",
	},
	{
		"Id": "Pattern Crafting",
		"Category": "Crafting Systems",
		"Tags": [ "crafting" ],
		"Implementations": [ "Minecraft" ],
		"Related Mechanics": [  ],
		"Scene" : "res://Mechanics/Pattern Crafting/Scenes/pattern_crafting.tscn",
		"Thumbnail" : "res://Mechanics/Pattern Crafting/thumbnail.png",
	},
]

var categories : Dictionary = {}
var tags : Dictionary = {}
var implementations : Dictionary = {}
var related_mechanics : Dictionary = {}
var thumbs : Dictionary = {}

func build_indices():
	categories = {}
	tags = {}
	implementations = {}
	related_mechanics = {}
	
	for mechanic in mechanics:
		_append_single(mechanic["Id"], categories, mechanic["Category"])
		_append_list(mechanic["Id"], tags, mechanic["Tags"])
		_append_list(mechanic["Id"], implementations, mechanic["Implementations"])
		_append_list(mechanic["Id"], related_mechanics, mechanic["Related Mechanics"])
		mechanic["Thumbnail"] = load(mechanic["Thumbnail"])

func _append_list(mechanic_id, index, index_key_list):
	for index_key in index_key_list:
		_append_single(mechanic_id, index, index_key)
		
func _append_single(mechanic_id, index, index_key):
	if (!index.has(index_key)):
		index[index_key] = Array()
	
	if (index[index_key].has(mechanic_id)):
		return
	
	index[index_key].append(mechanic_id)

