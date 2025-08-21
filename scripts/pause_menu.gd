extends Control


func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

func resume():
	get_tree().paused = false
	hide()

func pause():
	get_tree().paused = true
	show()

func _unhandled_input(event):
	if event.is_action_pressed("escape"):
		print("clicked")
		if get_tree().paused == false:
			pause()
		else:
			resume()

func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()

func _on_settings_pressed() -> void:
	pass # Open settings

func _on_quit_pressed() -> void:
	pass # Open main menu
