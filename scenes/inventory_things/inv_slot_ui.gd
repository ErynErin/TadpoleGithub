extends TextureButton

@export var item_display: Sprite2D

func update(slot: InvSlot):
	if !slot.item:
		item_display.visible = false
	else:
		item_display.visible = true
		item_display.texture = slot.item.texture
