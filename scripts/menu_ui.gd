extends Control

func _on_start_pressed() -> void:
	GameManager.load_to_scene("res://scenes/Main Scenes/nursery_scene.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_options_pressed() -> void:
	GameManager.show_options()
