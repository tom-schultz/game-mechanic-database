extends MechanicConfig
class_name BobberFishingConfig

var bob_speed = 2
var bob_distance = 2
var tiny_mass_hype = 1001
var state_change_time = 0.1
var score_range_min = 1
var score_range_max = 5

var state_config = {
	NoFish = {
		change_cooldown = 1.5,
		hit_cooldown = 1,
		pos_y_offset = 0,
		random_weight = 0.6,
	},
	Nibble = {
		change_cooldown = 0.2,
		hit_cooldown = 2,
		pos_y_offset = 7,
		random_weight = 0.3,
	},
	Bite = {
		change_cooldown = 0.6,
		hit_cooldown = 1,
		pos_y_offset = 12,
		random_weight = 0.2,
	},
}

func _ready():
	build_config_ui()