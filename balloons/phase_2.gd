extends AnimatedSprite2D

# The full scene file path to check against
const TARGET_SCENE_PATH: String = "res://scenes/Main Scenes/2nd_scene.tscn"

func _ready() -> void:
	update_visibility()
	get_tree().connect("scene_changed", _on_scene_changed)


func _on_scene_changed(new_scene: Node) -> void:
	update_visibility()


func update_visibility() -> void:
	var current_scene = get_tree().current_scene
	if not current_scene:
		visible = false
		return
	
	var current_scene_path = current_scene.scene_file_path
	# Debug print to check current scene path
	print("Current scene path:", current_scene_path)
	
	visible = (current_scene_path == TARGET_SCENE_PATH)


# Call this method externally when dialogue ends to hide the sprite
func hide_sprite_on_dialogue_end() -> void:
	visible = false
