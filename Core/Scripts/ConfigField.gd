extends SpinBox
class_name ConfigField

var line_edit

func _ready():
	line_edit = get_line_edit()
	

func _unhandled_input(event):
	
	if (line_edit.has_focus()
	and event is InputEventMouseButton
	and not line_edit.get_global_rect().has_point(event.position)):
		line_edit.release_focus()
