class_name CWM_EntityType

var id : String
var strong : Array
var color : String

func _init(name : String, data : Dictionary):
	self.id = name
	strong = data.strong
	color = data.color
