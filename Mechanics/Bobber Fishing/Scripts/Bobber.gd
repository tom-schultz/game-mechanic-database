extends Sprite2D
class_name Bobber

@export var cfg: BobberFishingConfig
@export var sfx_player: AudioStreamPlayer
@export var splash_sfx: AudioStream
@export var bloop_sfx: AudioStream
@export var bite_score_sfx: AudioStream

var counter = 0
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

signal fish_caught()

# Called when the node enters the scene tree for the first time.
func _ready():
	fish_state = FishState.NOFISH
	starting_pos = position
	target_pos = position
	fish_cooldown = cfg.state_config[fish_state].change_cooldown
	fish_state = FishState.NOFISH

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_fish_state(delta)
	move_bobber(delta)

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
	
	if (rand <= cfg.state_config.Bite.random_weight):
		set_state(FishState.BITE, false)
	elif (rand <=  cfg.state_config.Bite.random_weight + cfg.state_config.Nibble.random_weight):
		set_state(FishState.NIBBLE, false)
		
func move_bobber(delta):
	if (is_bobbing):
		counter += cfg.bob_speed * delta
		position = starting_pos + cfg.bob_distance * sin(counter) * Vector2.UP
	elif (!position.is_equal_approx(target_pos)):
		var y_dist = abs(target_pos.y - starting_pos.y)
		
		if fish_state == FishState.NOFISH:
			y_dist = cfg.state_config.Bite.pos_y_offset
			
		var pos_delta = y_dist * delta / cfg.state_change_time
		position = position.move_toward(target_pos, pos_delta)
		
		if (position.is_equal_approx(target_pos)):
			is_bobbing = fish_state == FishState.NOFISH
		
func hit():
	print_debug("Hit on fish state ", fish_state)
	
	if (fish_state == FishState.BITE):
		sfx_player.stream = bite_score_sfx
		fish_caught.emit()
	else:
		sfx_player.stream = splash_sfx
	
	sfx_player.play()
	var old_state = fish_state
	set_state(FishState.NOFISH, true)
	return old_state
	
func set_state(new_state, is_hit):
	if is_hit:
		fish_cooldown = cfg.state_config[fish_state].hit_cooldown
	else:
		fish_cooldown = cfg.state_config[new_state].change_cooldown
	
	if (fish_state != new_state):
		target_pos = starting_pos + cfg.state_config[new_state].pos_y_offset * Vector2.DOWN
		fish_state = new_state
		counter = 0
		is_bobbing = false
		next_state_check = Time.get_ticks_msec() + fish_cooldown * 1000 + 1000
	elif (fish_state == FishState.NOFISH):
		target_pos = starting_pos + cfg.bob_distance * Vector2.UP
		counter = PI / 2
		is_bobbing = false
