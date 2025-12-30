extends Node2D

@export var game_duration := 105
@export var max_simultaneous_falls := 3
@onready var timer_label = $"../CanvasLayer/Label"
@onready var items := [$Crayon, $Knife, $Needle, $Pencil, $Thorn]
const ENEMY_A = preload("res://scenes/Characters/worm2.tscn")
const ENEMY_B = preload("res://scenes/Characters/beetle2.tscn")
var spawn_toggle = false

var time_left = game_duration
var rng = RandomNumberGenerator.new()
var active_items = {} # Tracks currently falling items

func _ready() -> void:
	rng.randomize()

# ----------------------------
# TIMER
# ----------------------------
func start_timer() -> void:
	timer_label.text = format_time(time_left)

	var t = Timer.new()
	t.wait_time = 1.0
	t.one_shot = false
	add_child(t)
	t.timeout.connect(_on_second_passed)
	t.start()
	
	await get_tree().create_timer(10).timeout
	spawn_enemies()
	setup_enemy_spawner()

func _on_second_passed() -> void:
	time_left -= 1
	timer_label.text = format_time(time_left)

	if time_left < 0:
		time_left = 0
		timer_label.text = "0:00"
		await $"..".fade_in_screen()
		GameManager.load_to_scene("res://scenes/Main Scenes/2.6nd_scene.tscn")

func format_time(seconds: int) -> String:
	@warning_ignore("integer_division")
	return "%02d:%02d" % [seconds / 60, seconds % 60]

# ----------------------------
# FALL LOOP
# ----------------------------
func start_falling_loop() -> void:
	while time_left > 0:
		play_multiple_falls()
		await get_tree().create_timer(5.0).timeout

# ----------------------------
# MULTI FALL LOGIC
# ----------------------------
func play_multiple_falls() -> void:
	var available_items := []

	for item in items:
		if not active_items.has(item):
			available_items.append(item)

	if available_items.is_empty():
		return

	var fall_count := rng.randi_range(2, min(max_simultaneous_falls, available_items.size()))

	for i in fall_count:
		var item = available_items.pick_random()
		available_items.erase(item)
		start_item_fall(item)

func start_item_fall(item: Node2D) -> void:
	active_items[item] = true
	var anim: AnimationPlayer = item.get_node("AnimationPlayer")
	
	$Digging.play()
	anim.play("fall")
	await anim.animation_finished
	anim.play("appear")
	await anim.animation_finished

	active_items.erase(item)

# ----------------------------
# ENEMY SPAWNER
# ----------------------------
func setup_enemy_spawner() -> void:
	var spawn_timer = Timer.new()
	spawn_timer.wait_time = 20.0
	spawn_timer.autostart = true
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout() -> void:
	spawn_enemies()

func spawn_enemies() -> void:
	$Poof.play()
	var enemy_scene = ENEMY_A if spawn_toggle else ENEMY_B
	
	# Left Enemy
	var enemy_left = enemy_scene.instantiate()
	enemy_left.position = Vector2(-700, 400) # Adjust to your left spawn point
	get_parent().add_child(enemy_left)
	
	# Right Enemy
	var enemy_right = enemy_scene.instantiate()
	enemy_right.position = Vector2(700, 400) # Adjust to your right spawn point
	get_parent().add_child(enemy_right)
	
	if enemy_scene == ENEMY_A:
		enemy_left.scale = Vector2(0.5, 0.5)
		enemy_right.scale = Vector2(0.5, 0.5)
	else: 
		enemy_left.scale = Vector2(1.5, 1.5)
		enemy_right.scale = Vector2(1.5, 1.5)
	
	spawn_toggle = !spawn_toggle
