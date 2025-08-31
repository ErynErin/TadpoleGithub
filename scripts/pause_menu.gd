extends Control

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var audio_stream_player_2: AudioStreamPlayer = $AudioStreamPlayer2

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

func resume():
	get_tree().paused = false
	hide()

func pause():
	audio_stream_player.play()
	get_tree().paused = true
	show()

func _unhandled_input(event):
	if event.is_action_pressed("escape"):
		audio_stream_player_2.play()
		if get_tree().paused == false:
			pause()
		else:
			resume()

func _on_continue_pressed() -> void:
	audio_stream_player_2.play()
	resume()

func _on_options_pressed() -> void:
	audio_stream_player.play()
	GameManager.show_options()

func _on_quit_pressed() -> void:
	audio_stream_player.play()
	resume()
	get_tree().change_scene_to_file("res://scenes/Main Scenes/main_menu_ui.tscn")
