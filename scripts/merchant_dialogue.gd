extends Control

@onready var merchant: AnimatedSprite2D = $Merchant

func ready() -> void:
	merchant.play("talk")
