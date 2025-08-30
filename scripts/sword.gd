extends AnimatedSprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player = get_parent()
@onready var collision_shape_2d: CollisionShape2D = $HitBox/CollisionShape2D

var is_equipped = false

func sword_attack() -> void:
	animation_player.play("attack")
	play("attack")
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_equip"):
		is_equipped = not is_equipped
		self.visible = is_equipped
		collision_shape_2d.disabled = not is_equipped

func _on_hit_box_area_entered(area) -> void:
	if area is HurtBox and area.owner.has_method("take_damage"):
		area.owner.take_damage(GameManager.strength)
		print("Damage dealth to enemy: " + str(GameManager.strength))
