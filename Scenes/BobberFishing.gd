extends Node2D

var bobber

# Called when the node enters the scene tree for the first time.
func _ready():
	bobber = get_node("Bobber")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_key_input(event):
	if (event.is_pressed() and event.keycode == KEY_SPACE):
		bobber.hit()
