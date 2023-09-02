extends Resource
class_name BobberFishingConfig

@export var bob_speed : float = 2.0
@export var bob_distance : float = 2.0
@export var state_change_time : float = 0.1
@export var score_range_min : int = 1
@export var score_range_max : int = 5

@export var state_config = {
	NoFish = {
		change_cooldown = 1.5,
		hit_cooldown = 1.0,
		pos_y_offset = 0.0,
		random_weight = 0.6,
	},
	Nibble = {
		change_cooldown = 0.2,
		hit_cooldown = 2.0,
		pos_y_offset = 10.0,
		random_weight = 0.3,
	},
	Bite = {
		change_cooldown = 0.6,
		hit_cooldown = 1.0,
		pos_y_offset = 14.0,
		random_weight = 0.2,
	},
}
