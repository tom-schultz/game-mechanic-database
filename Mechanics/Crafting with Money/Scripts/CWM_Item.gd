class_name CWM_Item	

var name : String
var type : CWM_EntityType
var level : int

func _init(name : String, type : CWM_EntityType, level : int):
	self.name = name
	self.type = type
	self.level = level

func str():
	return "+%d %s of %s" % [level, name, type.id]
