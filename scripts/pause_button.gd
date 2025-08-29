extends Button

@onready var pause_menu: Control = $"../Pause Menu"

func _ready():
	self.pressed.connect(_on_pressed)
	
func _on_pressed():
	get_tree().paused = true
	pause_menu.show()
