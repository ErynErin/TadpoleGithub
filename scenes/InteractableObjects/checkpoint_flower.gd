extends AnimatedSprite2D

func _ready() -> void:
	play("closed_" + str(GameManager.phase_num))

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		play("bud_" + str(GameManager.phase_num))
		await animation_finished
		$Area2D.queue_free()
