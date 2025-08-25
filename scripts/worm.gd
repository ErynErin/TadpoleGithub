extends CharacterBody2D

const POISON_DAMAGE_PER_TICK = 5.0
const POISON_TICK_RATE = 2.0
const POISON_DURATION = 6.0 

var actual_speed: float = 0.0
var enemy_health = 50
var player_entered: bool = false
var is_poisoned: bool = false
var player_in_bite_range: bool = false
var poison_elapsed_time: float = 0.0

@onready var player = get_parent().find_child("player")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_detector: Area2D = $"Player Detector"
@onready var poison_timer: Timer = $Timer
@onready var bite_box: Area2D = $BiteBox

func _ready():
	actual_speed = (randi() % (100 - 40 + 1)) + 40
	print("Worm created with speed: ", actual_speed)
	sprite_2d.play("rest")

func _physics_process(delta):
	var direction : Vector2
	if is_instance_valid(player) and player_entered:
		direction = global_position.direction_to(player.global_position)
		global_position.x += direction.x * actual_speed * delta
		sprite_2d.play("crawl")
		if direction.x < 0:
			sprite_2d.flip_h = false
		else:
			sprite_2d.flip_h = true
	else:
		sprite_2d.play("rest")
		
	if is_poisoned:
		poison_elapsed_time += delta
		if poison_elapsed_time >= POISON_DURATION:
			if player_in_bite_range:
				poison_elapsed_time = 0.0
				print("Player remains in range. Poison effect CONTINUES.")
			else:
				is_poisoned = false
				poison_elapsed_time = 0.0
				poison_timer.stop()
				print("Poison effect worn off.")
	
func take_damage(damage: float) -> void:
	enemy_health -= damage
	animation_player.play("hurt")
	print("Remaining Worm Health: ", enemy_health)
	if enemy_health <= 0:
		queue_free()

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body == player:
		player_entered = true

func _on_player_detector_body_exited(body: Node2D) -> void:
	if body == player:
		player_entered = false

func _on_timer_timeout() -> void:
	if is_instance_valid(player) and is_poisoned:
		GameManager.take_damage(POISON_DAMAGE_PER_TICK)
		player._on_hurt_box_area_entered(null)

func _on_bite_box_area_entered(area) -> void:
	if area.owner != null and area.owner.is_in_group("player"):
		player_in_bite_range = true
		if !is_poisoned:
			print("Player has been poisoned!")
			is_poisoned = true
			poison_elapsed_time = 0.0 
			poison_timer.start(POISON_TICK_RATE) 
			GameManager.take_damage(POISON_DAMAGE_PER_TICK) 

func _on_bite_box_area_exited(area) -> void:
	if area.owner != null and area.owner.is_in_group("player"):
		player_in_bite_range = false
