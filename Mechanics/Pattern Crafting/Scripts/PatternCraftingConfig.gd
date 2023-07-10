extends MechanicConfig
class_name PatternCraftingConfig

var example_float : float = 2
var test_short_string : String = "dog"
@export_multiline var test_long_string : String = "doggggggggggggggggggggggggggggggggggggggggggggggggggggg"

# Called when the node enters the scene tree for the first time.
func _ready():
	build_config_ui()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
