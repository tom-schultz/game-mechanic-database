extends Resource
class_name CraftingAsAServiceConfig

signal types_changed

@export_multiline var types : String = """{
	"flaming": {
		"strong": ["living wood"],
		"color": "crimson"
	},
	"living wood": {
		"strong": ["earthen"],
		"color": "peru"
	},
	"aqueous": {
		"strong": ["flaming"],
		"color": "deep sky blue"
	},
	"earthen": {
		"strong": ["skyborn"],
		"color": "saddle brown"
	},
	"skyborn": {
		"strong": ["aqueous"],
		"color": "light steel blue"
	}
}""":
	set(value):
		types = value
		types_changed.emit()

@export var items_per_store : int = 5
@export var upgrade_cost_multiplier = 3
@export var purchase_cost_multiplier = 4
@export var strong_modifier = 2

@export var weapons : Array[String] = [
	"axe",
	"sword",
	"bow",
	"table leg",
	"crossbow",
	"wand",
	"wizard Staff",
	"quarterstaff",
	"sling",
	"dagger",
	"scimitar",
	"keyboard",
	"flail",
	"mace",
	"morningstar",
	"palm strike",
	"pinky hold",
	"baleful glare",
	"stink eye",
]

@export var armors : Array[String] = [
	"apathy",
	"platemail",
	"leather jerkin",
	"round shield",
	"tower shield",
	"kite shield",
	"trash can lid",
	"great helm",
	"trucker hat",
	"cuirass",
	"mage armor",
	"greaves",
	"codpiece",
	"pauldrons",
	"sneakers",
	"short shorts",
	"chainmail",
	"scalemail",
	"origami breastplate",
]

@export var enemies : Array[String] = [
	"lizardfolk",
	"eagle",
	"beagle",
	"goblin",
	"teenager",
	"programmer",
	"artist",
	"producer",
	"tester",
	"audio engineer",
	"MBA",
	"writer",
	"gamer",
	"monkey",
	"bear",
	"bug",
	"bugbear",
	"bearbug",
]

@export var enemy_levels : Array[String] = [
	"sickly",
	"weak",
	"young",
	"juvenile",
	"adult",
	"strong",
	"greater",
	"intelligent",
	"powerful",
	"ancient",
	"giant",
	"massive",
	"gargantuan",
	"titanic",
	"apocalyptic",
	"godlike",
]
