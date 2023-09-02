class_name CWM_Entity	

var name : String
var type : CWM_EntityType
var level : int
var _config : CraftingWithMoneyConfig

func _init(config : CraftingWithMoneyConfig, new_name : String, new_type : CWM_EntityType,
		new_level : int):
	self.name = new_name
	self.type = new_type
	self.level = new_level
	self._config = config

func upgrade_cost():
	return level * _config.upgrade_cost_multiplier + 1

func purchase_cost():
	return level * _config.purchase_cost_multiplier + 1

func to_str(use_level_string = false):
	var level_string = level_str() if use_level_string else "+%d" % [level]
	return "%s [color=%s]%s[/color] %s" % [level_string, type.color, type.id, name]

func level_str():
	return _config.enemy_levels[level]

func get_adjusted_level(opposing_type : CWM_EntityType):
	if type.strong.has(opposing_type.id):
		return level * _config.strong_modifier
	
	return level
