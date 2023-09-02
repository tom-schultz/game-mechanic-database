extends Resource
class_name PatternCraftingConfig

signal recipes_changed

@export_multiline var recipes : String = """fried_eggs:salt(0-2),egg(3-5),egg(3-5),butter(6-8)
flour:wheat(0-8)
bread:flour(0-8),flour(0-8),flour(0-8),water(0-8),salt(0-8)
sandwich:bread(0-2),fried_eggs(3-5),cheese(3-5),mayo(3-5),bread(6-8)
sandwich:bread(0-2),ham(3-5),cheese(3-5),mayo(3-5),bread(6-8)
grilled_cheese:bread(0-2),butter(3-5),cheese(3-5),bread(6-8)
frittata:egg(0-2),egg(0-2),egg(0-2),spinach(3-8),tomato(3-8),onion(3-8),cheese(3-8),salt(3-8),black_pepper(3-8)""":
	set(value):
		recipes = value
		recipes_changed.emit()
