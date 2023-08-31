extends Resource
class_name CraftingWithMoneyConfig

var money : int = 100

var types : Dictionary

var enemies : Array[String] = [
	"Lizardfolk",
	"Eagle",
	"Beagle",
	"Goblin",
	"Teenager",
	"Programmer",
	"Artist",
	"Producer",
	"Tester",
	"Audio Engineer",
	"MBA",
	"Writer",
	"Gamer",
	"Monkey",
	"Bear",
	"Bug",
	"Bugbear",
	"Bearbug",
]

var enemy_levels : Array[String] = [
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

func init():
	# This is here because I don't support rendering this kind of thing right now :D
	var types_data = {
		"Fire" = {
			Adjective = "Fire",
			Strong = ["Wooden"],
			Weak = ["Water"]
		},
		"Wood" = {
			Adjective = "Wooden",
			Strong = ["Water"],
			Weak = ["Fire"]
		},
		"Water" = {
			Adjective = "Water",
			Strong = ["Fire"],
			Weak = ["Wooden"]
		}
	}
	
	for type in types_data:
		types[type] = CWM_EntityType.new(type, types_data[type])
