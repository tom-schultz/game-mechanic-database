extends Node
class_name CraftingAsAService

@export var config : CraftingAsAServiceConfig
@export var adv_text : RichTextLabel
@export var coins_label : Label
@export var inventory_grid : GridContainer
@export var weapon_store_grid : GridContainer
@export var armor_store_grid : GridContainer
@export var button_scene : PackedScene
@export var buy_sfx : AudioStream
@export var upgrade_sfx : AudioStream
@export var stalemate_sfx : AudioStream
@export var victory_sfx : AudioStream
@export var defeat_sfx : AudioStream

var weapons : Array[CAAS_Entity]
var armors : Array[CAAS_Entity]
var weapon_store : Array[CAAS_Entity]
var armor_store : Array[CAAS_Entity]
var coins = 3
var types : Dictionary

func _ready():
	config.types_changed.connect(_reset)
	_reset()

func _reset():
	_update_types()
	
	weapons = [
		CAAS_Entity.new(config, config.weapons.pick_random(), rand_type(), 1),
	]
	
	armors = [
		CAAS_Entity.new(config, config.armors.pick_random(), rand_type(), 1),
	]
	
	_update_inventory()
	_update_store()

func _update_types():
	var types_data = JSON.parse_string(config.types)
	types.clear()
	
	for key in types_data:
		types[key] = CAAS_EntityType.new(key, types_data[key])

func _update_inventory():
	coins_label.text = "Coins: " + String.num(coins)
	
	for child in inventory_grid.get_children():
		child.queue_free()
		
	_add_items_to_inv_grid(weapons, true)
	_add_items_to_inv_grid(armors, false)
	
func _update_store():
	weapon_store.clear()
	armor_store.clear()
	
	for i in range(0, config.items_per_store):
		var item_name = config.weapons.pick_random()
		var item_type = rand_type()
		var item_level = randi_range(0, _player_level())
		var item = CAAS_Entity.new(config, item_name, item_type, item_level)
		weapon_store.append(item)
		
	for i in range(0, config.items_per_store):
		var item_name = config.armors.pick_random()
		var item_type = rand_type()
		var item_level = randi_range(0, _player_level())
		var item = CAAS_Entity.new(config, item_name, item_type, item_level)
		armor_store.append(item)
	
	_redraw_store(true)
	_redraw_store(false)

func _redraw_store(is_weapon : bool):
	var item_store = weapon_store if is_weapon else armor_store
	var store_grid = weapon_store_grid if is_weapon else armor_store_grid
	
	for dying in store_grid.get_children():
		dying.queue_free()
	
	for i in range(0, item_store.size()):
		var label = RichTextLabel.new()
		label.text = item_store[i].to_str()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		label.add_theme_color_override("default_color", Color.html("222323"))
		label.fit_content = true
		label.bbcode_enabled = true
		store_grid.add_child(label)
		
		var btn : Button = button_scene.instantiate()
		btn.text = "Buy: " + String.num(item_store[i].purchase_cost())
		btn.pressed.connect(_on_buy_btn_pressed.bind(is_weapon, i))
		btn.disabled = coins < item_store[i].purchase_cost()
		store_grid.add_child(btn)

func _on_buy_btn_pressed(is_weapon : bool, store_index : int):
	var items = weapons if is_weapon else armors
	var item_store = weapon_store if is_weapon else armor_store
		
	if coins >= item_store[store_index].purchase_cost():
		coins -= item_store[store_index].purchase_cost()
		items.append(item_store[store_index])
		item_store.remove_at(store_index)
		_update_inventory()
		_redraw_store(true)
		_redraw_store(false)
		AudioPlayer.play_sfx(buy_sfx)

func _add_items_to_inv_grid(collection, is_weapon):
	for i in range(0, collection.size()):
		var label = RichTextLabel.new()
		label.text = collection[i].to_str()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		label.add_theme_color_override("default_color", Color.html("222323"))
		label.fit_content = true
		label.bbcode_enabled = true
		inventory_grid.add_child(label)
		
		var btn : Button = button_scene.instantiate()
		btn.text = "Upgrade: " + String.num(collection[i].upgrade_cost())
		btn.pressed.connect(_on_upgrade_btn_pressed.bind(is_weapon, i))
		btn.disabled = coins < collection[i].upgrade_cost()
		inventory_grid.add_child(btn)

func _on_upgrade_btn_pressed(is_weapon : bool, index : int):
	var items : Array[CAAS_Entity] = weapons if is_weapon else armors
	
	if coins >= items[index].upgrade_cost():
		coins -= items[index].upgrade_cost()
		items[index].level += 1
		_update_inventory()
		_redraw_store(true)
		_redraw_store(false)
		AudioPlayer.play_sfx(upgrade_sfx)

func _get_best_item(collection : Array[CAAS_Entity], enemy : CAAS_Entity):
	var best_level = collection[0].get_adjusted_level(enemy.type)
	var best_item = collection[0]
	
	for item in collection:
		var adjusted_level = item.get_adjusted_level(enemy.type)
		
		if adjusted_level > best_level:
			best_level = adjusted_level
			best_item = item
	
	print_rich("%s : %s" % [enemy.to_str(), best_item.to_str()])
	return best_item

func _player_level():
	var highest_weapon : float = 0
	var highest_armor : float = 0
	
	for item in weapons:
		if item.level > highest_weapon:
			highest_armor = item.level
			
	for item in armors:
		if item.level > highest_armor:
			highest_armor = item.level
	
	return roundi((highest_weapon + highest_armor) / 2)

func _generate_enemy():
	var max_level = config.enemy_levels.size() - 1
	var rand = randfn(_player_level() * 0.9, 1.0 + _player_level() / 2.0)
	var enemy_level =  roundi(clampf(rand, 0, max_level))
	var enemy_type = rand_type()
	var enemy_name = config.enemies.pick_random()
	var enemy = CAAS_Entity.new(config, enemy_name, enemy_type, enemy_level)
	return enemy

func _get_result(enemy, weapon, armor, initiative):
	var result = "Stalemate"
	var wep_success = _test_item(weapon, enemy)
	var armor_success = _test_item(armor, enemy)
	
	if initiative:
		if wep_success:
			result = "Victory"
		elif not armor_success:
			result = "Defeat"
	else:
		if not armor_success:
			result = "Defeat"
		elif wep_success:
			result = "Victory"
	
	return result
	
func _build_outcome(result, enemy, weapon, armor, initiative):
	var outcome = ""
	var enemy_string = enemy.to_str(true)
	
	if result == "Stalemate":
		outcome = "[center]Stalemate!\n\nToo evenly matched, you decide to disengage from the " \
			+ enemy_string + ".[/center]"
	else:
		var victory = result == "Victory"
		var initiative_phrase = "You snuck up on" if initiative else "You were ambushed by"
		var item_string = weapon.to_str() if victory else armor.to_str()
		var result_phrase = "was overcome by" if victory else "overcame"
		var aeiou = "n" if "aeiou".contains(enemy.level_str()[0].to_lower()) else ""
		
		outcome = "[center]%s!\n\n%s a%s %s who %s your %s.[/center]" % [
			result,
			initiative_phrase,
			aeiou,
			enemy_string,
			result_phrase,
			item_string
		]
	
	if result == "Victory":
		coins += clampi(randi_range(enemy.level - 3, enemy.level + 3), 1, 999)
		coins_label.text = "Coins: " + String.num(coins)
		_update_inventory()
	
	return outcome

func _on_adventure_pressed():
	var enemy = _generate_enemy()	
	var weapon = _get_best_item(weapons, enemy)
	var armor = _get_best_item(armors, enemy)
	
	var initiative = (randi() % 2) == 1
	var result = _get_result(enemy, weapon, armor, initiative)
	var outcome = _build_outcome(result, enemy, weapon, armor, initiative)
	print(outcome)
	adv_text.text = outcome
	_update_store()
	
	match (result):
		"Victory":
			AudioPlayer.play_sfx(victory_sfx)
		"Defeat":
			AudioPlayer.play_sfx(defeat_sfx)
		"Stalemate":
			AudioPlayer.play_sfx(stalemate_sfx)

func _test_item(item : CAAS_Entity, enemy : CAAS_Entity):	
	return item.get_adjusted_level(enemy.type) > enemy.level

func rand_type():
	return types[types.keys().pick_random()]
