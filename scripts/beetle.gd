extends CharacterBody2D

const WALK_SPEED = 65.0
const ATTACK_SPEED = 200.0
const JUMP_VELOCITY = -600.0
const WALK_DISTANCE = 200.0
const CHARGE_DURATION = 1.5
const VULNERABLE_DURATION = 3.0
const ATTACK_DURATION = 1.0
const STANDING_DURATION = 3.0

enum State { STAND, CRAWL, CHARGE, ATTACK, VULNERABLE }

@onready var player = get_parent().find_child("player")
@onready var hurt_box: HurtBox = $HurtBox
@onready var hit_box: Area2D = $HitBox
@onready var sprite_2d: AnimatedSprite2D = $Pivot/Sprite2D
@onready var pivot: Node2D = $Pivot
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_detector: Area2D = $"Player Detector"

var current_state = State.STAND
var state_timer: float = 0.0
var distance_traveled: float = 0.0
var direction: float = 1.0
var enemy_health = 20
var is_player_in_range: bool = false

func _ready() -> void:
	print("Beetle spawned. Initial state: STAND")
	_change_state(State.STAND)

func _physics_process(delta: float) -> void:	
	match current_state:
		State.STAND:
			_stand_state(delta)
		State.CRAWL:
			_crawl_state(delta)
		State.CHARGE:
			_charge_state(delta)
		State.ATTACK:
			_attack_state(delta)
		State.VULNERABLE:
			_vulnerable_state(delta)
	
	if not is_on_floor():
		velocity += get_gravity() * delta

# Handles the STAND state logic.
func _stand_state(delta: float) -> void:
	state_timer += delta
	if state_timer >= STANDING_DURATION:
		print("STAND duration finished. Transitioning to CRAWL.")
		pivot.scale.x = -direction
		_change_state(State.CRAWL)

# Handles the CRAWL state logic.
func _crawl_state(delta: float) -> void:
	# Move the beetle horizontally.
	velocity.x = direction * WALK_SPEED
	move_and_slide()
	
	distance_traveled += WALK_SPEED * delta
	
	# Check if the beetle has traveled its walking distance.
	if distance_traveled >= WALK_DISTANCE:
		print("CRAWL distance reached. Reversing direction and transitioning to STAND.")
		distance_traveled = 0.0
		direction *= -1 # Reverse direction.
		_change_state(State.STAND)

# Handles the CHARGE state logic.
func _charge_state(delta: float) -> void:
	state_timer += delta
	if state_timer >= CHARGE_DURATION:
		print("CHARGE duration finished. Transitioning to ATTACK.")
		_change_state(State.ATTACK)
	
	# Optional: Face the player during charge.
	if player:
		pivot.scale.x = -sign(player.global_position.x - global_position.x)

# Handles the ATTACK state logic.
func _attack_state(delta: float) -> void:
	state_timer += delta
	velocity.x = sign(player.global_position.x - global_position.x) * ATTACK_SPEED
	
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		print("ATTACK started. Jumping.")
	
	# After the attack duration, reset the state.
	if state_timer >= ATTACK_DURATION:
		print("ATTACK duration finished. Checking for player hit.")
		# Check the collision status from the hitbox.
		var player_hit = false
		for body in hit_box.get_overlapping_bodies():
			if body == player:
				player_hit = true
				break
		
		# Implement the pseudocode logic.
		if player_hit:
			print("Player was hit.")
			# Player was hit, loop back to charge if in range.
			if is_player_in_range:
				print("Player still in range. Looping to CHARGE.")
				_change_state(State.CHARGE)
			else:
				print("Player out of range. Transitioning to CRAWL.")
				_change_state(State.CRAWL) # Or STAND, depending on desired idle state.
		else:
			print("Player avoided the attack. Transitioning to VULNERABLE.")
			# Player avoided the attack, become vulnerable.
			_change_state(State.VULNERABLE)

# Handles the VULNERABLE state logic.
func _vulnerable_state(delta: float) -> void:
	state_timer += delta
	if state_timer >= VULNERABLE_DURATION:
		print("VULNERABLE duration finished. Transitioning to STAND.")
		_change_state(State.STAND)

# Main state transition function.
func _change_state(new_state) -> void:
	print("Changing state from ", current_state, " to ", new_state)
	current_state = new_state
	state_timer = 0.0
	
	match current_state:
		State.STAND:
			hurt_box.set_deferred("monitoring", false)
			hit_box.set_deferred("monitoring", false)
			sprite_2d.play("stand")
		State.CRAWL:
			hurt_box.set_deferred("monitoring", false)
			hit_box.set_deferred("monitoring", false)
			sprite_2d.play("crawl")
		State.CHARGE:
			hurt_box.set_deferred("monitoring", false)
			hit_box.set_deferred("monitoring", false)
			sprite_2d.play("charge")
		State.ATTACK:
			hurt_box.set_deferred("monitoring", false)
			hit_box.set_deferred("monitoring", true)
			sprite_2d.play("attack")
		State.VULNERABLE:
			hurt_box.set_deferred("monitoring", true)
			hit_box.set_deferred("monitoring", false)

# Signals to handle player detection.
func _on_player_detector_body_entered(body: Node2D) -> void:
	if body == player:
		is_player_in_range = true
		print("Player entered detection area. is_player_in_range = ", is_player_in_range)
		if current_state != State.CHARGE and current_state != State.ATTACK:
			print("Player detected, not in a locked state. Transitioning to CHARGE.")
			_change_state(State.CHARGE)

func _on_player_detector_body_exited(body: Node2D) -> void:
	if body == player:
		is_player_in_range = false
		print("Player exited detection area. is_player_in_range = ", is_player_in_range)

func _on_hit_box_area_entered(area) -> void:
	print("Hitbox collided with an area.")
	if area.owner != null and area.owner.is_in_group("player") and current_state == State.ATTACK:
		print("Player hit! Dealing damage.")
		GameManager.take_damage(10) # Player takes damage

func take_damage(damage: float) -> void:
	enemy_health -= damage
	animation_player.play("hurt")
	print("Beetle Health: ", enemy_health)
	if enemy_health <= 0:
		print("Beetle defeated! Queueing free.")
		queue_free()
