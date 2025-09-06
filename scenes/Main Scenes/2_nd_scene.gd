extends Node2D

@onready var screen_fade = $CanvasLayer/ScreenFade
@onready var dialogue_resource: DialogueResource = preload("res://dialogues/p2_tutorial.dialogue")
var balloon_scene = preload("res://balloons/SystemBalloon.tscn")  # Your custom balloon scene

func _ready():
	GameManager.current_scene_path = "res://scenes/Main Scenes/2nd_scene.tscn"
	
	screen_fade.color.a = 1.0
	screen_fade.set_z_index(1000)
	await fade_out_screen()
	
	var balloon_instance = balloon_scene.instantiate()
	get_tree().current_scene.add_child(balloon_instance)

	# Connect dialogue finished signal
	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	# Start the pre-shop dialogue
	balloon_instance.start(dialogue_resource, "start")


func _on_dialogue_ended(_resource):
	DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)
	
	
func fade_in_screen():
	var tween = create_tween()
	tween.tween_property(screen_fade, "color:a", 1.0, 1.5)
	await tween.finished

func fade_out_screen():
	var tween = create_tween()
	tween.tween_property(screen_fade, "color:a", 0.0, 1.5)
	await tween.finished
