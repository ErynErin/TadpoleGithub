extends Area2D

@onready var interaction_area: InteractionArea = $InteractionArea
@export var item: InvItem

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
		
func _on_interact():
	GameManager.collect(item)
	queue_free()
