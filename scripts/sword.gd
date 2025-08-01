extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func sword_attack() -> void:
	animation_player.play("attack")
	print("Dealt Damage")
