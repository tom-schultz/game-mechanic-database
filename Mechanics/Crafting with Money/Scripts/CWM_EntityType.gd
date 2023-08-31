class_name CWM_EntityType

var id : String
var adjective : String
var strong : Array
var weak : Array

func _init(id : String, data : Dictionary):
	self.id = id
	adjective = data.Adjective
	strong = data.Strong
	weak = data.Weak
