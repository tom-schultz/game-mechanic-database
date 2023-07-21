extends MenuButton
class_name ExitButton

const CONFIRM_BTN = 0

func _ready():
	get_popup().id_pressed.connect(_menu_press)

func _menu_press(button_id : int):
	AudioPlayer.play_button_press_sfx()
	
	if button_id != CONFIRM_BTN:
		return
	
	if OS.has_feature('web'):
		JavaScriptBridge.eval("""
			window.history.back()
		""")
	else:
		get_tree().quit()


func _on_pressed():
	AudioPlayer.play_button_press_sfx()
