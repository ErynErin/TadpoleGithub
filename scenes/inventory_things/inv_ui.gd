extends Control

@onready var inv: Inv = preload("res://scenes/inventory_things/player_inventory.tres")
@onready var slots: Array = $VBoxContainer.get_children()

func _ready():
	inv.update.connect(update_slots)
	update_slots()

func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])

func _on_texture_button_pressed() -> void:
	pass # Replace with function body.
