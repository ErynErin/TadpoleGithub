extends AnimatedSprite2D

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready():
	play("idle")
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	GameManager.show_dialogue("MerchantDialogue")
	play("talk")
	await get_tree().create_timer(3.0).timeout
	GameManager.hide_dialogue("MerchantDialogue")
	GameManager.show_shop()
	play("idle")
