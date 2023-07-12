class_name Recipe

var output : InventoryItem
var _conditions : Array

# fried_eggs:egg(0-2),egg(0-2),butter(3-5)
func _init(recipe_str: String):
	var sections = recipe_str.split(":", false)
	assert(sections.size() == 2, "Recipe string should contain two colon-delimited sections: " + recipe_str)
	output = InventoryItem.new(sections[0])
	var condition_strings = sections[1].split(",", false)
	assert(condition_strings.size() >= 1, "Recipe string should contain at least one condition: " + recipe_str)
	
	for condition_string in condition_strings:
		_conditions.append(RecipeCondition.new(condition_string))

func check_recipe(items : Array):
	var consumed : Array = Array()
	
	var matched = _conditions.all(func(cond):
		for i in range(cond.range_start, cond.range_end + 1):
			if (!consumed.has(i) and items[i] == cond.item):
				consumed.append(i)
				return true
		
		return false
	)
	
	var item_count = items.size() - items.count("")
	return matched && consumed.size() == item_count

class RecipeCondition:
	var item : String
	var range_start : int
	var range_end : int
	
	static var _regex = RegEx.create_from_string("(?<item>[a-zA-Z_]*)\\((?<count_min>[0-8])-(?<count_max>[0-8])\\)")
	
	func _init(condition_str : String):
		var result = _regex.search(condition_str)
		
		if (result):
			assert(result.get_group_count() == 3, "Couldn't find all sections of condition string: " + condition_str)
			item = result.get_string("item")
			range_start = result.get_string("count_min").to_int()
			range_end = result.get_string("count_max").to_int()
	
