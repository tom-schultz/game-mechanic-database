extends Mechanic

var bobber
var cfg_bobber_speed = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	bobber = get_node("Bobber")
	_build_config_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_key_input(event):
	if (event.is_pressed() and event.keycode == KEY_SPACE):
		bobber.hit()
