extends Node

@export var config : BobberFishingConfig
@export var bobber : Sprite2D
@export var hit_sfx: AudioStream
@export var _hit_sfx_volume : float = 1
@export var bite_score_sfx: AudioStream
@export var _bite_score_sfx_volume : float = 1
@export var _nibble_sfx : AudioStream
@export var _nibble_sfx_volume : float = 1
@export var _bite_sfx : AudioStream
@export var _bite_sfx_volume : float = 1

@onready var score_control : Label = get_node("Score")
@onready var fisherman : Label = get_node("Fisherman")

var score = 0
const default_fisherman = "(ఠ‿ఠ)"
var fisherman_reset_counter = 0
var bob_counter = 0
var starting_pos: Vector2
var target_pos: Vector2
var fish_state
var fish_cooldown = 0
var is_bobbing = true
var next_state_check: float

const FishState = {
	NOFISH = "NoFish",
	NIBBLE = "Nibble",
	BITE = "Bite"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	fisherman.text = default_fisherman
	fish_state = FishState.NOFISH
	starting_pos = bobber.position
	target_pos = bobber.position
	fish_cooldown = config.state_config[fish_state].change_cooldown
	fish_state = FishState.NOFISH

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_fish_state(delta)
	move_bobber(delta)

func _unhandled_key_input(event):
	if (event.is_pressed()):
		match (event.keycode):
			KEY_SPACE:
				print_debug("Received action button!")
				_do_hit()
			KEY_1:
				set_state(FishState.NOFISH, false)
			KEY_2:
				set_state(FishState.NIBBLE, false)
			KEY_3:
				set_state(FishState.BITE, false)
	
func _do_hit():	
	match (fish_state):
		FishState.NOFISH:
			fisherman.text = "(ఠ_ఠ)"
			AudioPlayer.play_sfx(hit_sfx, _hit_sfx_volume)
		FishState.NIBBLE:
			fisherman.text = "(ఠ౧ఠ)"
			AudioPlayer.play_sfx(hit_sfx, _hit_sfx_volume)
		FishState.BITE:
			AudioPlayer.play_sfx(bite_score_sfx, _bite_score_sfx_volume)
			fisherman.text = "\\ (ఠ‿ఠ) /"
			print("You GO Fish Coco!")
			score += randi_range(config.score_range_min, config.score_range_max)
			score_control.text = "Score: " + String.num(score)
	
	set_state(FishState.NOFISH, true)
	_reset_fisherman()

func _reset_fisherman():
	fisherman_reset_counter += 1
	await get_tree().create_timer(1).timeout
	fisherman_reset_counter -= 1
	
	if (fisherman_reset_counter == 0):
		fisherman.text = default_fisherman

func _on_fish_caught():
	print("You GO Fish Coco!")
	score += randi_range(config.score_range_min, config.score_range_max)
	score_control.text = "Score: " + String.num(score)

func update_fish_state(delta):
	if (fish_cooldown > 0):
		fish_cooldown -= delta
		return
	
	if (fish_state != FishState.NOFISH):
		set_state(FishState.NOFISH, false)
		return
	
	var time = Time.get_ticks_msec()
	
	if (time < next_state_check):
		return
	
	next_state_check = time + 1000
	var rand = randf()
	
	if (rand <= config.state_config.Bite.random_weight):
		set_state(FishState.BITE, false)
	elif (rand <=  config.state_config.Bite.random_weight + config.state_config.Nibble.random_weight):
		set_state(FishState.NIBBLE, false)
		
func move_bobber(delta):
	if (is_bobbing):
		bob_counter += config.bob_speed * delta
		bobber.position = starting_pos + config.bob_distance * sin(bob_counter) * Vector2.UP
	elif (!bobber.position.is_equal_approx(target_pos)):
		var y_dist = abs(target_pos.y - starting_pos.y)
		
		if fish_state == FishState.NOFISH:
			y_dist = config.state_config.Bite.pos_y_offset
			
		var pos_delta = y_dist * delta / config.state_change_time
		bobber.position = bobber.position.move_toward(target_pos, pos_delta)
		
		if (bobber.position.is_equal_approx(target_pos)):
			is_bobbing = fish_state == FishState.NOFISH
	
func set_state(new_state, is_hit):
	if new_state == FishState.NIBBLE:
		AudioPlayer.play_sfx(_nibble_sfx, _nibble_sfx_volume)
	elif new_state == FishState.BITE:
		AudioPlayer.play_sfx(_bite_sfx, _bite_sfx_volume)
	
	if is_hit:
		fish_cooldown = config.state_config[fish_state].hit_cooldown
	else:
		fish_cooldown = config.state_config[new_state].change_cooldown
	
	if (fish_state != new_state):
		target_pos = starting_pos + config.state_config[new_state].pos_y_offset * Vector2.DOWN
		fish_state = new_state
		bob_counter = 0
		is_bobbing = false
		next_state_check = Time.get_ticks_msec() + fish_cooldown * 1000 + 1000
	elif (fish_state == FishState.NOFISH):
		target_pos = starting_pos + config.bob_distance * Vector2.UP
		bob_counter = PI / 2
		is_bobbing = false
