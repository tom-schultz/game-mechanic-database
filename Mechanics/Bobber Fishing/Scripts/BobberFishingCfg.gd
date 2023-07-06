extends MechanicCfg
class_name BobberFishingCfg

@export var c_state_config = {
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

@export var c_bob_speed = 2
@export var c_bob_distance = 3
@export var c_tiny_mass_power_level = 9001
@export var c_state_change_time = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	property_prefix = "c_"
	build_config_ui()
	load_description("res://Mechanics/Bobber Fishing/description.txt")
