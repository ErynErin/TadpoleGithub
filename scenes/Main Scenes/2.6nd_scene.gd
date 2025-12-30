extends Node2D

@onready var screen_fade = $GUI/ScreenFade
@onready var boss_dialogue_resource: DialogueResource = preload("res://dialogues/boss.dialogue")
var boss_balloon_scene = preload("res://balloons/Boss2Balloon.tscn")

func _init() -> void:
	GameManager.phase_num = 2.6

func _ready():
	GameManager.starting_health = GameManager.current_health
	GameManager.current_scene_path = "res://scenes/Main Scenes/1st_scene.tscn"
	
	screen_fade.color.a = 1.0
	screen_fade.set_z_index(1000)
	await fade_out_screen()

func start_dialogue(title: String, make_player_movable: bool, balloon):
	GameManager.set_player_movable(make_player_movable)

	var balloon_instance = balloon.instantiate()
	get_tree().current_scene.add_child(balloon_instance)

	# Connect dialogue finished signal once
	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	balloon_instance.start(boss_dialogue_resource, title)

func _on_dialogue_ended(_resource):
	GameManager.set_player_movable(true)
	
	if has_node("AnglerFish"):
		$AnglerFish._on_light_detection_area_body_entered($player)
	
func fade_in_screen():
	var tween = create_tween()
	tween.tween_property(screen_fade, "color:a", 1.0, 1.5)
	await tween.finished

func fade_out_screen():
	var tween = create_tween()
	tween.tween_property(screen_fade, "color:a", 0.0, 1.5)
	await tween.finished

func _on_boss_dialogue_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.set_player_movable(false)

		var balloon_instance = boss_balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon_instance)

		# Connect dialogue finished signal once
		if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
			DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

		balloon_instance.start(boss_dialogue_resource, "p2_start")
		$"Boss Dialogue Area".queue_free()
