extends Node2D

@onready var video_player = $VideoStreamPlayer
@onready var intro_dialogue = preload("res://dialogues/p1_intro.dialogue")

@onready var system_balloon_scene = preload("res://balloons/SystemBalloon.tscn")

@onready var player = $player
@onready var anim_player = $AnimationPlayer

func _ready():
	# Start with player invisible and input disabled or enabled depending on your game logic
	player.modulate.a = 0.0  # fully transparent
	player.visible = false    # keep it visible so it can receive input, or false if you want invisible before fade

	player.set_physics_process(false)  # or false if you want player disabled during video

	video_player.finished.connect(_on_video_finished)
	video_player.play()

func _on_video_finished():
	print("Video finished!")

	# Start fading the player in
	fade_in_player()

	# Instantiate and start dialogue balloon
	var balloon_instance = system_balloon_scene.instantiate()
	get_tree().current_scene.add_child(balloon_instance)

	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	balloon_instance.start(intro_dialogue, "start")

func fade_in_player():
	player.visible = true  # Make player visible before fading
	player.set_physics_process(true)  # Enable player physics/process if needed

	var tween = create_tween()
	tween.tween_property(player, "modulate:a", 1.0, 2.0)  # fade alpha from 0 to 1 in 2 seconds


func _on_dialogue_ended(_resource):
	if DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)

	# Do whatever after dialogue ends, e.g. enable other UI or start gameplay
	pass
