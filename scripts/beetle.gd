extends CharacterBody2D

const SPEED = 300.0
const ATTACK_SPEED = 600.0
const JUMP_VELOCITY = -400.0
const CHARGE_DURATION = 1.5 # Time (in seconds) the beetle charges
const VULNERABLE_DURATION = 3.0
const ATTACK_DURATION = 1.0 # Time (in seconds) for the attack run

enum State { REST, CHARGE, ATTACK, VULNERABLE }
var current_state = State.REST

const PATROL_RANGE = 100.0 # Distance to move before turning (in studs/pixels)
var initial_x: float = 0.0 # Starting X position for current patrol cycle
var current_x: float = 0.0

var player_entered: bool = false
var enemy_health = 20
var direction: int = 1

@onready var player = get_parent().find_child("player")
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var charge_timer: Timer = $ChargeTimer
@onready var vulnerable_timer: Timer = $VulnerableTimer
@onready var attack_timer: Timer = $AttackTimer
#@onready var wall_check: RayCast2D = $WallCheck
@onready var hurt_box: HurtBox = $HurtBox
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

func _ready():
	initial_x = global_position.x
	sprite_2d.play("rest")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Movement speed to be applied outside the match block
	var horizontal_speed = 0.0
	current_x = global_position.x

	match current_state:
		State.REST:
			if player_entered:
				set_state(State.CHARGE)
				return # Exit early to prevent patrol logic from running

			# 1. Check patrol distance
			var distance_traveled = abs(current_x - initial_x)
			
			print("REST state. Current X:", round(current_x), ", Distance traveled:", round(distance_traveled))
			# 2. Check turn conditions (range limit or wall/edge)
			# WallCheck must be pointed in the current 'direction' (x: 40 * direction, y: 0)
			if distance_traveled >= PATROL_RANGE: #  or wall_check.is_colliding()
				direction *= -1
				initial_x = current_x
				if direction < 0:
					sprite_2d.flip_h = true
				else:
					sprite_2d.flip_h = false

			# 3. Apply crawl movement and animation
			horizontal_speed = direction * SPEED
			sprite.play("crawl") # Use the crawl animation

		State.CHARGE:
			velocity.x = 0
			direction = sign(player.global_position.x - global_position.x)
			if direction < 0:
				sprite_2d.flip_h = true
			else:
				sprite_2d.flip_h = false

		State.ATTACK:
		# Apply attack speed movement
			horizontal_speed = direction * ATTACK_SPEED
			# Check for obstacles to jump over
			#if is_on_floor() and wall_check.is_colliding():
				#velocity.y = JUMP_VELOCITY

		State.VULNERABLE:
			# Stand still
			horizontal_speed = 0.0 
			# HurtBox is enabled during this state (handled in set_state)

	# Apply velocity and slide (Modified: apply speed unless attacking)
	if current_state != State.ATTACK:
	# Use move_toward for smooth acceleration/deceleration during REST
		velocity.x = move_toward(velocity.x, horizontal_speed, SPEED * delta)
	else:
	# Directly set attack speed for instant acceleration
		velocity.x = horizontal_speed

	move_and_slide()
	
func set_state(new_state) -> void:	
	if current_state == new_state:
		return
		
	current_state = new_state
	print("Beetle state changed to: ", current_state)
	
	match current_state:
		State.REST:
			direction = 1
			initial_x = global_position.x
			sprite.play("crawl")
			initial_x = global_position.x
			hurt_box.monitoring = true
			$HitBox.monitoring = false
		
		State.CHARGE:
			sprite.play("charge")
			charge_timer.start(CHARGE_DURATION)
			hurt_box.monitoring = false
			
		State.ATTACK:
			sprite.play("attack")
			$HitBox.monitoring = true
			attack_timer.start(ATTACK_DURATION)

		State.VULNERABLE:
			# Use the 'rest' animation or a dedicated 'stunned' animation
			sprite.play("rest") 
			# VULNERABLE state means the HurtBox is fully active and the beetle is stunned
			hurt_box.monitoring = true 
			$HitBox.monitoring = false
			vulnerable_timer.start(VULNERABLE_DURATION) # Start countdown to REST

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body == player:
		print("player entered")
		player_entered = true
		if current_state == State.REST: # Immediately start charging
			set_state(State.CHARGE)
		
func _on_player_detector_body_exited(body: Node2D) -> void:
	if body == player:
		print("Player left the detection area.")
		player_entered = false

func _on_charge_timer_timeout() -> void:
	if current_state == State.CHARGE:
		print("Charge timer timed out! Transitioning to ATTACK.")
		set_state(State.ATTACK)

func _on_vulnerable_timer_timeout() -> void:
	if current_state == State.VULNERABLE:
		print("Vulnerability timer timed out! Transitioning back to REST.")
		set_state(State.REST)

func take_damage(damage_amount: int) -> void:
	if current_state == State.VULNERABLE:
		enemy_health -= damage_amount
		$AnimationPlayer.play("hurt")
		
		print("Beetle took damage! Current health: ", enemy_health)
		
		if enemy_health <= 0:
			queue_free()
	else:
		# Optionally provide feedback that the attack was blocked/no damage was taken
		print("Beetle is invincible!")

func _on_attack_timer_timeout() -> void:
	if current_state == State.ATTACK:
		print("Attack timer finished. Transitioning to VULNERABLE state.")
		set_state(State.VULNERABLE)
