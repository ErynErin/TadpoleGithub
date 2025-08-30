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
		if get_tree().paused == false:
			pause()
		else:
			resume()

func _on_continue_pressed() -> void:
	resume()

func _on_options_pressed() -> void:
	GameManager.show_options()

func _on_quit_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://scenes/Main Scenes/main_menu_ui.tscn")
