extends Area2D

@onready var food: Area2D = $"."
@onready var interaction_area: InteractionArea = $InteractionArea

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	
func _on_interact():
	GameManager.add_hunger()
	food.queue_free()
