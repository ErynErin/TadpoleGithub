extends Node2D

@onready var video_player = $VideoStreamPlayer
@onready var intro_dialogue = preload("res://dialogues/p1_intro.dialogue")

# Preload your custom balloon scenes
var system_balloon_scene = preload("res://balloons/SystemBalloon.tscn")
var player_balloon_scene = preload("res://balloons/Player1Balloon.tscn")

func _ready():
	video_player.finished.connect(_on_video_finished)
	video_player.play()

func _on_video_finished():
	print("Video finished!")

	# Instantiate the custom balloon
	var balloon_instance = system_balloon_scene.instantiate()
	get_tree().current_scene.add_child(balloon_instance)

	# Connect to the DialogueManager's signal to detect when the dialogue ends
	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	# Start the dialogue
	balloon_instance.start(intro_dialogue, "start")

func _on_dialogue_ended(_resource):
	# Disconnect to prevent multiple calls
	if DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)

	# Change to the next scene
	get_tree().change_scene_to_file("res://scenes/Main Scenes/nursery_scene.tscn")
