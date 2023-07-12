extends TextEdit
class_name ConfigFieldLongString

func _unhandled_input(event: InputEvent):
	var is_enter_event = event is InputEventKey and event.keycode == KEY_ENTER
	var is_click_outside = event is InputEventMouseButton and not get_global_rect().has_point(event.position)
	
	if (has_focus() and (is_enter_event or is_click_outside)):
		release_focus()
