extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func sword_attack() -> void:
	animation_player.play("attack")
	print("Dealt Damage")

func _on_hit_box_body_entered(body: Node2D) -> void:
	body.take_damage()
