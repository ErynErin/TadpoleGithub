extends CharacterBody2D
#@onready var animation_player: AnimationPlayer = $AnimationPlayer

const JUMP_VELOCITY = -600.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sword: Node2D = $Sword

func _physics_process(delta: float) -> void:
	var SPEED = GameManager.speed
	
# Get the input direction and handle the movement/deceleration.	
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
		animated_sprite.flip_h = true
	elif direction > 0:
		animated_sprite.flip_h = false
	
	if is_on_floor():
		if Input.is_action_just_pressed("attack"):
			#animated_sprite.play("attack") # Temporary and very buggy
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
