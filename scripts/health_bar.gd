extends ProgressBar

func _ready():
	GameManager.health_changed.connect(_on_health_changed)

func _on_health_changed(current_health: float, max_health: float):
	max_value = max_health
	value = current_health
	
