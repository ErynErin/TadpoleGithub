extends Control

@onready var shop_panel: Panel = $"Shop Panel"
@onready var exit_shop: Button = $"Shop Panel/Exit Shop"

@onready var health_label: Label = $"Shop Panel/Current Stats/Health Label"
@onready var strength_label: Label = $"Shop Panel/Current Stats/Strength Label"
@onready var speed_label: Label = $"Shop Panel/Current Stats/Speed Label"

func _on_exit_shop_pressed():
	GameManager.hide_shop()

func _on_health_button_pressed():
	GameManager.add_health()
	health_label.text = "Health: " + str(GameManager.max_health)
	GameManager.hide_shop()
	
func _on_strength_button_pressed():
	GameManager.add_strength()
	strength_label.text = "Strength: " + str(GameManager.strength)
	GameManager.hide_shop()

func _on_speed_button_pressed():
	GameManager.add_speed()
	speed_label.text = "Speed: " + str(GameManager.speed)
	GameManager.hide_shop()
