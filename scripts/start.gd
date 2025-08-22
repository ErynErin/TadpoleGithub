extends TextureButton

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main Scenes/nursery_scene.tscn")
