extends AnimatedSprite2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var dialogue_resource: DialogueResource = preload("res://dialogues/p1_merchant.dialogue")
var balloon_scene = preload("res://balloons/MerchantBalloon.tscn")  # Your custom balloon scene

var can_interact := false


func _ready():
	play("idle")
	interaction_area.interact = Callable(self, "_on_interact")


func _on_interact():
	can_interact = false  # Disable re-interaction during the sequence

	# Create and show the balloon
	var balloon_instance = balloon_scene.instantiate()
	get_tree().current_scene.add_child(balloon_instance)

	# Connect dialogue finished signal
	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	# Start the pre-shop dialogue
	balloon_instance.start(dialogue_resource, "start")

	play("talk")


func _on_dialogue_ended(_resource):
	DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)

	# Show the shop UI
	GameManager.show_shop()

	# Connect to shop_closed to wait before showing afterbuy dialogue
	if not GameManager.shop_closed.is_connected(_on_shop_closed):
		GameManager.shop_closed.connect(_on_shop_closed)

	play("idle")


func _on_shop_closed():
	GameManager.shop_closed.disconnect(_on_shop_closed)

	# Create and show the post-shop dialogue
	var after_balloon = balloon_scene.instantiate()
	get_tree().current_scene.add_child(after_balloon)

	if not DialogueManager.dialogue_ended.is_connected(_on_final_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_final_dialogue_ended)

	after_balloon.start(dialogue_resource, "afterbuy")

	play("talk")


func _on_final_dialogue_ended(_resource):
	DialogueManager.dialogue_ended.disconnect(_on_final_dialogue_ended)
	play("idle")
	can_interact = true  # Re-enable interaction if needed
