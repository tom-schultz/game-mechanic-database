extends Node

@export var cfg : BobberFishingConfig
@onready var bobber : Bobber = get_node("Bobber")
@onready var score_control : Label = get_node("Score")
@onready var fisherman : Label = get_node("Fisherman")
var score = 0
const default_fisherman = "(ఠ‿ఠ)"
var reset_counter = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	bobber.fish_caught.connect(_on_fish_caught)
	fisherman.text = default_fisherman

func _unhandled_key_input(event):
	if (event.is_pressed()):
		match (event.keycode):
			KEY_SPACE:
				print_debug("Received action button!")
				_do_hit()
			KEY_1:
				bobber.set_state(Bobber.FishState.NOFISH, false)
			KEY_2:
				bobber.set_state(Bobber.FishState.NIBBLE, false)
			KEY_3:
				bobber.set_state(Bobber.FishState.BITE, false)

func _do_hit():
	var state = bobber.hit()
	
	match (state):
		Bobber.FishState.NOFISH:
			fisherman.text = "(ఠ_ఠ)"
		Bobber.FishState.NIBBLE:
			fisherman.text = "(ఠ౧ఠ)"
		Bobber.FishState.BITE:
			fisherman.text = "\\ (ఠ‿ఠ) /"
	
	_reset_fisherman()

func _reset_fisherman():
	reset_counter += 1
	await get_tree().create_timer(1).timeout
	reset_counter -= 1
	
	if (reset_counter == 0):
		fisherman.text = default_fisherman

func _on_fish_caught():
	print("You GO Fish Coco!")
	score += randi_range(cfg.score_range_min, cfg.score_range_max)
	score_control.text = "Score: " + String.num(score)
