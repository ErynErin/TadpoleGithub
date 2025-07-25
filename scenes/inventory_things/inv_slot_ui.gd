extends Panel

@onready var item_display: Sprite2D = $"CenterContainer/Panel/Item Display"

func update(slot: InvSlot):
	if !slot.item:
		item_display.visible = false
	else:
		item_display.visible = true
		item_display.texture = slot.item.texture
