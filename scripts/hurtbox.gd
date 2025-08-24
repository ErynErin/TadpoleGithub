class_name HurtBox

extends Area2D

@export var damage := 10

func _ready() -> void:
	connect("area_entered", self._on_area_entered)

func _on_area_entered(hitbox) -> void:
	if hitbox == null or hitbox is not HitBox:
		return
