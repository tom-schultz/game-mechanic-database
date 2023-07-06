extends Sprite2D

signal missed_fish(bool)
signal fish_caught()

@export var cfg: MechanicCfg
var counter = 0
var starting_pos: Vector2
var target_pos: Vector2
var fish_state
var fish_cooldown = 0
var is_bobbing = true
var next_state_check: float

const FishState = {
	NONE = "NoFish",
	NIBBLE = "Nibble",
	BITE = "Bite"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	fish_state = FishState.NONE
	starting_pos = position
	target_pos = position
	fish_cooldown = cfg.c_state_config[fish_state].change_cooldown
	fish_state = FishState.NONE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_fish_state(delta)
	move_bobber(delta)

func update_fish_state(delta):
	if (fish_cooldown > 0):
		fish_cooldown -= delta
		return
	
	if (fish_state != FishState.NONE):
		set_state(FishState.NONE, false)
		return
	
	var time = Time.get_ticks_msec()
	
	if (time < next_state_check):
		return
	
	next_state_check = time + 1000
	var rand = randf()
	
	if (rand <= cfg.c_state_config.Bite.random_weight):
		set_state(FishState.BITE, false)
	elif (rand <=  cfg.c_state_config.Bite.random_weight + cfg.c_state_config.Nibble.random_weight):
		set_state(FishState.NIBBLE, false)
		
func move_bobber(delta):
	if (is_bobbing):
		counter += cfg.c_bob_speed * delta
		position = starting_pos + cfg.c_bob_distance * sin(counter) * Vector2.UP
	elif (!position.is_equal_approx(target_pos)):
		var y_dist = abs(target_pos.y - starting_pos.y)
		
		if fish_state == FishState.NONE:
			y_dist = cfg.c_state_config.Bite.pos_y_offset
			
		var pos_delta = y_dist * delta / cfg.c_state_change_time
		position = position.move_toward(target_pos, pos_delta)
		
		if (position.is_equal_approx(target_pos)):
			is_bobbing = fish_state == FishState.NONE
		
func hit():
	print_debug("Hit on fish state ", fish_state)
	
	match (fish_state):
		FishState.NIBBLE:
			missed_fish.emit(fish_state == FishState.NIBBLE)
		FishState.BITE:
			fish_caught.emit()
	
	set_state(FishState.NONE, true)
	
func set_state(new_state, is_hit):
	if is_hit:
		fish_cooldown = cfg.c_state_config[fish_state].hit_cooldown
	else:
		fish_cooldown = cfg.c_state_config[new_state].change_cooldown
	
	if (fish_state != new_state):
		target_pos = starting_pos + cfg.c_state_config[new_state].pos_y_offset * Vector2.DOWN
		fish_state = new_state
		counter = 0
		is_bobbing = false
		next_state_check = Time.get_ticks_msec() + fish_cooldown * 1000 + 1000
