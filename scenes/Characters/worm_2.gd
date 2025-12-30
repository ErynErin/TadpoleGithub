extends CharacterBody2D

const POISON_DAMAGE_PER_TICK = 5.0
const POISON_TICK_RATE = 2.0
const POISON_DURATION = 6.0 

var actual_speed: float = 0.0
var enemy_health = 40
var player_entered: bool = true
var is_poisoned: bool = false
var player_in_bite_range: bool = false
var outside: bool = true
var spawning = 0
var poison_elapsed_time: float = 0.0

@onready var player = get_parent().find_child("player")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: AnimatedSprite2D = $Pivot/AnimatedSprite2D
@onready var poison_timer: Timer = $Timer
@onready var coin_scene = preload("res://scenes/Collectibles/food.tscn")
@onready var pivot: Node2D = $Pivot

func _ready():
	actual_speed = (randi() % (100 - 40 + 1)) + 40
	print("Worm created with speed: ", actual_speed)
	#animation_player.play("crawl")
	
func _physics_process(delta):
	var direction : Vector2
	if is_instance_valid(player) and player_entered and outside:
		direction = global_position.direction_to(player.global_position)
		global_position.x += direction.x * actual_speed * delta
		sprite_2d.play("crawl")
		if direction.x < 0:
			pivot.scale.x = 1
		else:
			pivot.scale.x = -1
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
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	
func take_damage(damage: float) -> void:
	enemy_health -= damage
	animation_player.play("hurt")
	print("Remaining Worm Health: ", enemy_health)
	if enemy_health <= 0:
		$AudioStreamPlayer2.play()
		await $AudioStreamPlayer2.finished
		var coin_instance = coin_scene.instantiate()
		coin_instance.global_position = global_position
		get_parent().add_child(coin_instance)
		GameManager.add_enemies_killed()
		queue_free()

func _on_timer_timeout() -> void:
	if is_instance_valid(player) and is_poisoned:
		GameManager.take_damage(POISON_DAMAGE_PER_TICK)
		player._on_hurt_box_area_entered(null)

func _on_bite_box_area_entered(area) -> void:
	if area.owner != null and area.owner.is_in_group("player"):
		player_in_bite_range = true
		if is_poisoned:
			return
		elif !is_poisoned:
			print("Player has been poisoned!")
			$AudioStreamPlayer.play()
			is_poisoned = true
			poison_elapsed_time = 0.0 
			poison_timer.start(POISON_TICK_RATE) 
			GameManager.take_damage(POISON_DAMAGE_PER_TICK) 

func _on_bite_box_area_exited(area) -> void:
	if area.owner != null and area.owner.is_in_group("player"):
		player_in_bite_range = false
