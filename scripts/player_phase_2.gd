extends CharacterBody2D

const JUMP_VELOCITY = -600.0

@onready var sword: Node2D = $Sword
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pivot: Node2D = $Pivot
@onready var animated_sprite: AnimatedSprite2D = $Pivot/AnimatedSprite2D

func _ready():
	set_physics_process(true)
	GameManager.hunger = 0
	GameManager.max_health = 100.0
	GameManager.current_health = 100.0
	GameManager.strength = 10
	GameManager.speed = 200
	GameManager.player_died.connect(_on_player_died)

func _physics_process(delta: float) -> void:
	var SPEED = GameManager.speed
	if GameManager.current_health <= 0:
		return
	
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED # go
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED) # stop
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if Input.is_action_just_pressed("jump"):    # fix to do double jump only :D
			velocity.y = JUMP_VELOCITY
			
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle sprint.
	if Input.is_action_pressed("Sprint") and Input.get_axis("left", "right"):
		velocity.x = move_toward(velocity.x, (velocity.x * 2), SPEED)
				
	if direction < 0:
		pivot.scale.x = direction
		sword.scale.x = direction
	elif direction > 0:
		pivot.scale.x = direction
		sword.scale.x = direction
	
	if is_on_floor():
		if Input.is_action_just_pressed("attack"):
			sword.sword_attack()
		if direction == 0:
			animated_sprite.play("idle")
		elif Input.is_action_pressed("Sprint"):
			animated_sprite.play("run")
		else:
			animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")

	move_and_slide()

func take_damage(damage: float):
	GameManager.take_damage(damage)

func _on_hurt_box_area_entered(_area) -> void:
	animation_player.play("hurt")

func _on_player_died():
	print("Player is dead. Playing death animation and restarting.")
	set_physics_process(false)
	animated_sprite.play("death")
	GameManager.player_died.disconnect(_on_player_died)
	await animated_sprite.animation_finished
	get_tree().reload_current_scene()
