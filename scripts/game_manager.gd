extends Node

var hunger = 0
var max_health = 100.0
var current_health = 100.0
var strength = 50
var speed = 200
@export var inv: Inv

func add_hunger():
	if hunger != 5:
		hunger += 1
		print("hunger:", hunger)
		var current_scene = get_tree().current_scene
		var hunger_lower_bar = current_scene.get_node("GUI/hunger lower bar")
		match hunger:
			1:
				hunger_lower_bar.region_rect = Rect2(0, 0, 215, 1000)
				hunger_lower_bar.size.x = 54.0
				print("num 1")
			2:
				hunger_lower_bar.region_rect = Rect2(0, 0, 410, 1000)
				hunger_lower_bar.size.x = 102.0
				print("num 2")
			3:
				hunger_lower_bar.region_rect = Rect2(0, 0, 600, 1000)
				hunger_lower_bar.size.x = 150.0
				print("num 3")
			4:
				hunger_lower_bar.region_rect = Rect2(0, 0, 790, 1000)
				hunger_lower_bar.size.x = 198.0
				print("num 4")
			5:
				hunger_lower_bar.region_rect = Rect2(0, 0, 0, 0)
				hunger_lower_bar.size.x = 250.0
				print("num 5")
	else:
		hunger += 1
		print("hunger: ", hunger, "more than 5")

func add_health():
	max_health += 50
	print("health: ", max_health)
	
func add_strength():
	strength += 50
	print("strength: ", strength)
	
func add_speed():
	speed += 50
	print("speed:", speed)

func show_dialogue(dialogue_scene):
	var current_scene = get_tree().current_scene
	var dialogue = current_scene.get_node("GUI/" + dialogue_scene)
	dialogue.visible = true
	
func hide_dialogue(dialogue_scene):
	var current_scene = get_tree().current_scene
	var dialogue = current_scene.get_node("GUI/" + dialogue_scene)
	dialogue.visible = false

func show_shop():
	var current_scene = get_tree().current_scene
	var merchant_dialogue = current_scene.get_node("GUI/MerchantDialogue")
	
	var merchant_shop = current_scene.get_node("GUI/merchant shop")
	merchant_shop.visible = true
	
func hide_shop():
	var current_scene = get_tree().current_scene
	var merchant_shop = current_scene.get_node("GUI/merchant shop")
	merchant_shop.visible = false

signal health_changed(current_health: float, max_health: float)

func take_damage(damage: float):
	current_health -= damage
	current_health = max(current_health, 0)  # Don't go below 0
	health_changed.emit(current_health, max_health)

func heal(amount: float):
	current_health += amount
	current_health = min(current_health, max_health)  # Don't exceed max
	health_changed.emit(current_health, max_health)

func set_health(new_health: float):
	current_health = clamp(new_health, 0, max_health) 
	health_changed.emit(current_health, max_health)

# Format for damage and heal
#func _ready():
	#pressed.connect(_on_pressed)
#
#func _on_pressed():
	#GameManager.take_damage(10)

func collect(item):
	inv.insert(item)
