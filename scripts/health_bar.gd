extends TextureProgressBar

func _ready():
	GameManager.health_changed.connect(_on_health_changed)
	
	max_value = GameManager.max_health
	value = GameManager.current_health

func _on_health_changed(current_health: float, max_health: float):
	max_value = max_health
	value = current_health
