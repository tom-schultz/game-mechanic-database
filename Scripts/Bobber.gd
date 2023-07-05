extends Sprite2D

signal missed_fish(bool)
signal fish_caught()

@export var bob_speed = 1
@export var bob_distance = 1
@export var state_change_time = 0.1
var counter = 0
var starting_pos: Vector2
var target_pos: Vector2
var fish_state = "None"
var fish_cooldown = 0
var is_bobbing = true
var next_state_check: float

@export var fish_state_config = {
	NONE = {
		hit_cooldown = 1,
		change_cooldown = 1.5,
		pos_y_offset = 0,
	},
	NIBBLE = {
		hit_cooldown = 2,
		change_cooldown = 0.2,
		random_weight = 0.3,
		pos_y_offset = 5,
	},
	BITE = {
		hit_cooldown = 3,
		change_cooldown = 0.75,
		random_weight = 0.2,
		pos_y_offset = 10,
	},
}

const FishState = {
	NONE = "NONE",
	NIBBLE = "NIBBLE",
	BITE = "BITE"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	starting_pos = position
	target_pos = position
	fish_cooldown = fish_state_config.NONE.change_cooldown

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
	var bite_weight = fish_state_config[FishState.BITE].random_weight
	var nibble_weight = fish_state_config[FishState.BITE].random_weight
	
	if (rand <= bite_weight):
		set_state(FishState.BITE, false)
	elif (rand <= bite_weight + nibble_weight):
		set_state(FishState.NIBBLE, false)
		
func move_bobber(delta):
	if (is_bobbing):
		counter += bob_speed * delta
		position = starting_pos + bob_distance * sin(counter) * Vector2.UP
	elif (!position.is_equal_approx(target_pos)):
		var y_dist = abs(target_pos.y - position.y)
		var pos_delta = y_dist * delta / state_change_time
		position = position.move_toward(target_pos, pos_delta)
		
		if (position.is_equal_approx(target_pos)):
			is_bobbing = fish_state == FishState.NONE
		
func hit():
	print_debug("Hit on fish state ", fish_state)
	
	match (fish_state):
		FishState.NONE, FishState.NIBBLE:
			missed_fish.emit(fish_state == FishState.NIBBLE)
		FishState.BITE:
			fish_caught.emit()
	set_state(FishState.NONE, true)
	
func set_state(new_state, is_hit):
	fish_state = new_state
	
	if is_hit:
		fish_cooldown = fish_state_config[new_state].hit_cooldown
	else:
		fish_cooldown = fish_state_config[new_state].change_cooldown
	
	target_pos = starting_pos + fish_state_config[fish_state].pos_y_offset * Vector2.DOWN
	counter = 0
	is_bobbing = false
	next_state_check = Time.get_ticks_msec() + fish_cooldown * 1000 + 1000

func _on_bobber_config_updated(path, value):
	var keys = path.split(".")
	var curr = fish_state_config
	
	for key in keys.slice(0, -2):
		curr = curr[key]
	
	curr[keys[-1]] = value.to_float()
