extends AnimatedSprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player = get_parent()

func sword_attack() -> void:
	animation_player.play("attack")
	play("attack")

func _on_hit_box_area_entered(area) -> void:
	if area is HurtBox:
		area.owner.take_damage(GameManager.strength)
		print("Damage dealth to enemy: " + str(GameManager.strength))
