extends CanvasLayer

# TODO: this is actually focus_entered (button_pressed didn't work)
func again_button_pressed():
	get_tree().reload_current_scene()
	get_tree().paused = false
