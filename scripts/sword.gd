extends Node2D

@onready var player = get_parent()
@onready var collision_shape_2d: CollisionShape2D = $HitBox/CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_equipped = false

func _ready() -> void:
	is_equipped = false
	self.visible = false
	collision_shape_2d.set_deferred("disabled", true)
	collision_shape_2d.set_deferred("monitoring", false)
	collision_shape_2d.set_deferred("monitorable", false)

func sword_attack() -> void:
	animation_player.play("attack")
	animated_sprite_2d.play("attack")
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_equip"):
		is_equipped = not is_equipped
		self.visible = is_equipped
		collision_shape_2d.set_deferred("disabled", not is_equipped)

func _on_hit_box_area_entered(area) -> void:
	if area is HurtBox and area.owner.has_method("take_damage"):
		area.owner.take_damage(GameManager.strength)
		print("Damage dealth to enemy: " + str(GameManager.strength))
