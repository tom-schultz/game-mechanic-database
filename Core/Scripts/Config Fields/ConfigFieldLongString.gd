extends TextEdit
class_name ConfigFieldLongString

func initialize():
	var children = get_children(true)
	
	for child in children:
		if child is VScrollBar:
			child.z_index = -1

func _unhandled_input(event: InputEvent):
	var is_click_outside = event is InputEventMouseButton and not get_global_rect().has_point(event.position)
	
	if (has_focus() and is_click_outside):
		release_focus()
