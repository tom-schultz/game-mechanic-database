extends Node
class_name CraftingWithMoney

@export var config : CraftingWithMoneyConfig
@export var adv_text : RichTextLabel

var weapons : Array[CWM_Item]
var armors : Array[CWM_Item]

enum result {
	FIRST,
	SECOND,
	STALEMATE
}

func _ready():
	config.init()
	
	weapons = [
		CWM_Item.new("Axe", config.types["Fire"], 10),
	]
	
	armors = [
		CWM_Item.new("Paper Armor", config.types["Wood"], 4),
	]

func _get_weapon():
	var weapon = weapons[randi() % weapons.size()]
	var weapon_str = "Weapon: " + weapon.str()
	print(weapon_str)
	adv_text.append_text(weapon_str + "\n")
	return weapon

func _get_armor():
	var armor = armors[randi() % armors.size()]
	var armor_str = "Armor: " + armor.str()
	print(armor_str)
	adv_text.append_text(armor_str + "\n")
	return armor

func _on_adventure_pressed():
	print("\nNew adventure!")
	adv_text.append_text("### New Adventure ###\n")
	var weapon = _get_weapon()
	var armor = _get_armor()

	var player_level = (weapon.level + armor.level) / 2
	var max_level = config.enemy_levels.size() - 1
	var rand = randfn(player_level, 1 + player_level / 2)
	var enemy_level =  clampf(rand, 0, max_level)
	var enemy_level_string = config.enemy_levels[enemy_level]
	var enemy_type = config.types.keys()[randi() % config.types.size()]
	var enemy_name = config.enemies[randi() % config.enemies.size()]
	var enemy = CWM_Item.new(enemy_name, config.types[enemy_type], enemy_level)
	
	var enemy_string = "%s (%d) %s %s" % [
		enemy_level_string,
		enemy_level,
		config.types[enemy_type].adjective,
		enemy_name
	]
	
	var enemy_str = "Enemy: " + enemy_string
	print(enemy_str)
	adv_text.append_text(enemy_str + "\n")
	
	var player_initiative = (randi() % 2) == 1
	var result = "Stalemate"
	var reversal = false
	
	if player_initiative:
		if _test_items(weapon, enemy):
			result = "Victory"
		elif _test_items(enemy, armor):
			result = "Defeat"
			reversal = true
	else:
		if _test_items(enemy, armor):
			result = "Defeat"
		elif _test_items(weapon, enemy):
			result = "Victory"
			reversal = true
	
	var outcome = ""
	
	if result == "Stalemate":
		outcome = "You disengage from " + enemy_string
	else:
		var victory = result == "Victory"
		var initiative_phrase = "You snuck up on" if player_initiative else "You were ambushed by"
		var item_string = weapon.str() if victory else armor.str()
		var result_phrase = "was overcome by" if victory else "was too much for"
		var reversal_string = ""
		
		if reversal:
			var reversal_phrase = "couldn't get past" if victory else "too tough for"
			var reversal_item = armor.str() if victory else weapon.str()
			reversal_string = "%s your %s and " % [reversal_phrase, reversal_item]
		
		outcome = "%s! %s a %s who %s%s your %s" % [
			result,
			initiative_phrase,
			enemy_string,
			reversal_string,
			result_phrase,
			item_string
		]
	
	print(outcome)
	adv_text.append_text(outcome + "\n\n")
	adv_text.scroll_following = true

func _test_items(item_attack : CWM_Item, item_defend : CWM_Item):
	var multiplier = 1
	
	if item_attack.type.strong.has(item_defend.type.id):
		multiplier = 2
	elif item_attack.type.weak.has(item_defend.type.id):
		multiplier = 0.5
	
	return item_attack.level * multiplier > item_defend.level
