extends Control

@onready var button_audio: AudioStreamPlayer = $ButtonAudio
@onready var start_audio: AudioStreamPlayer = $StartAudio

func _on_start_pressed() -> void:
	start_audio.play()
	get_tree().change_scene_to_file("res://scenes/intro_scene.tscn")

func _on_quit_pressed() -> void:
	button_audio.play()
	get_tree().quit()

func _on_options_pressed() -> void:
	button_audio.play()
	GameManager.show_options()
