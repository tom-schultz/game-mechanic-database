extends Resource
class_name LibraryDatabase

var mechanics : Array = [
	{
		"Id": "Bobber Fishing",
		"Category": "Timed Action",
		"Tags": [ "fishing" ],
		"Related Games": [ "World of Warcraft" ],
		"Related Mechanics": [ "BobberFishing2", "BobberFishing3", "Bobber Fishing4", "Bobber Fishing5" ],
	},
	{
		"Id": "Bobber Fishing2",
		"Category": "Timed Action2",
		"Tags": [ "fishing1" ],
		"Related Games": [ "World of Warcraft" ],
		"Related Mechanics": [ "Bobber Fishing", "BobberFishing3", "Bobber Fishing4", "Bobber Fishing5" ],
	},
	{
		"Id": "Bobber Fishing3",
		"Category": "Timed Action2",
		"Tags": [ "fishing2" ],
		"Related Games": [ "World of Warcraft" ],
		"Related Mechanics": [ "Bobber Fishing", "BobberFishing2", "Bobber Fishing4", "Bobber Fishing5" ],
	},
	{
		"Id": "Bobber Fishing4",
		"Category": "Timed Action3",
		"Tags": [ "fishing2" ],
		"Related Games": [ "World of Warcraft2" ],
		"Related Mechanics": [ "Bobber Fishing", "BobberFishing2", "BobberFishing3", "Bobber Fishing5" ],
	},
	{
		"Id": "Bobber Fishing5",
		"Category": "Timed Action3",
		"Tags": [ "fishing3" ],
		"Related Games": [ "World of Warcraft3", "Minecraft" ],
		"Related Mechanics": [ "Bobber Fishing", "BobberFishing2", "BobberFishing3", "Bobber Fishing4" ],
	},
	{
		"Id": "Pattern Crafting",
		"Category": "Crafting Systems",
		"Tags": [ "crafting" ],
		"Related Games": [ "Minecraft" ],
		"Related Mechanics": [ "Pattern Crafting2", "Pattern Crafting3", "Pattern Crafting4", "Pattern Crafting5" ],
	},
	{
		"Id": "Pattern Crafting2",
		"Category": "Crafting Systems2",
		"Tags": [ "crafting" ],
		"Related Games": [ "Minecraft" ],
		"Related Mechanics": [ "Pattern Crafting", "Pattern Crafting3", "Pattern Crafting4", "Pattern Crafting5" ],
	},
	{
		"Id": "Pattern Crafting3",
		"Category": "Crafting Systems2",
		"Tags": [ "crafting2" ],
		"Related Games": [ "Minecraft2" ],
		"Related Mechanics": [ "Pattern Crafting", "Pattern Crafting2", "Pattern Crafting4", "Pattern Crafting5" ],
	},
	{
		"Id": "Pattern Crafting4",
		"Category": "Crafting Systems3",
		"Tags": [ "crafting2" ],
		"Related Games": [ "Minecraft3" ],
		"Related Mechanics": [ "Pattern Crafting", "Pattern Crafting2", "Pattern Crafting3", "Pattern Crafting5" ],
	},
	{
		"Id": "Pattern Crafting5",
		"Category": "Crafting Systems3",
		"Tags": [ "crafting3" ],
		"Related Games": [ "Minecraft", "World of Warcraft" ],
		"Related Mechanics": [ "Pattern Crafting", "Pattern Crafting2", "Pattern Crafting3", "Pattern Crafting4" ],
	},
]

var categories : Dictionary = {}
var tags : Dictionary = {}
var related_games : Dictionary = {}
var related_mechanics : Dictionary = {}

func build_indices():
	categories = {}
	tags = {}
	related_games = {}
	related_mechanics = {}
	
	for mechanic in mechanics:
		_append_single(mechanic["Id"], categories, mechanic["Category"])
		_append_list(mechanic["Id"], tags, mechanic["Tags"])
		_append_list(mechanic["Id"], related_games, mechanic["Related Games"])
		_append_list(mechanic["Id"], related_mechanics, mechanic["Related Mechanics"])

func _append_list(mechanic_id, index, index_key_list):
	for index_key in index_key_list:
		_append_single(mechanic_id, index, index_key)
		
func _append_single(mechanic_id, index, index_key):
	if (!index.has(index_key)):
		index[index_key] = Array()
	
	if (index[index_key].has(mechanic_id)):
		return
	
	index[index_key].append(mechanic_id)

