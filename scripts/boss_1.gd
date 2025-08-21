extends Node2D

var enemy_health = 50
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func take_damage(amount: int) -> void:
	enemy_health -= 10
	animation_player.play("hurt")
	print("Remaining Health: ", enemy_health)
	if enemy_health <= 0:
		queue_free()
