extends Resource

class_name Inv

signal update

@export var slots: Array[InvSlot]

func insert(item: InvItem):
	var item_slots = slots.filter(func(slot): return slot.item == item)
	if !item_slots.is_empty():
		item_slots[0].amount += 1
	else:
		var empty_slots = slots.filter(func(slot): return slot.item == null)
		if !empty_slots.is_empty():
			empty_slots[0].item = item
			empty_slots[0].amount = 1
			
	for i in range(slots.size()): # Debugging
		if slots[i] != null and slots[i].item != null:
			print("Slot ", i, ": ", slots[i].item.name, " x", slots[i].amount)
	update.emit()
