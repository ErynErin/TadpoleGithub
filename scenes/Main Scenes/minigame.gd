extends Node2D

@export var game_duration := 90
@export var max_simultaneous_falls := 3
@onready var timer_label = $"../CanvasLayer/Label"

@onready var items := [$Crayon, $Knife, $Needle, $Pencil, $Thorn]

var time_left := game_duration
var rng := RandomNumberGenerator.new()
var active_items := {} # Tracks currently falling items

func _ready() -> void:
	rng.randomize()
	start_timer()
	start_falling_loop()

# ----------------------------
# TIMER
# ----------------------------
func start_timer() -> void:
	timer_label.text = format_time(time_left)

	var t := Timer.new()
	t.wait_time = 1.0
	t.one_shot = false
	add_child(t)
	t.timeout.connect(_on_second_passed)
	t.start()

func _on_second_passed() -> void:
	time_left -= 1
	timer_label.text = format_time(time_left)

	if time_left <= 0:
		get_tree().change_scene("res://scenes/Main Scenes/2nd_scene.tscn")

func format_time(seconds: int) -> String:
	return "%02d:%02d" % [seconds / 60, seconds % 60]

# ----------------------------
# FALL LOOP
# ----------------------------
func start_falling_loop() -> void:
	while time_left > 0:
		play_multiple_falls()
		await get_tree().create_timer(get_fall_delay()).timeout

func get_fall_delay() -> float:
	if time_left > 30:
		return rng.randf_range(3.0, 4.0)
	else:
		return rng.randf_range(2.0, 3.0)

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

	anim.play("fall")
	await anim.animation_finished
	anim.play("appear")
	await anim.animation_finished

	active_items.erase(item)
