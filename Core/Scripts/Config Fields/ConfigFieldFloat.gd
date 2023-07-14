extends SpinBox
class_name ConfigFieldFloat

var line_edit

func _ready():
	line_edit = get_line_edit()
	

func _unhandled_input(event: InputEvent):
	var is_enter_event = event is InputEventKey and event.keycode == KEY_ENTER
	var is_click_outside = event is InputEventMouseButton and not line_edit.get_global_rect().has_point(event.position)
	
	if (line_edit.has_focus() and (is_enter_event or is_click_outside)):
		line_edit.release_focus()
