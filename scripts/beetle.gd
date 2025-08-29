extends CharacterBody2D

const WALK_SPEED = 65.0
const ATTACK_SPEED = 400.0
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
var has_jumped: bool = false # Add this flag
var player_was_hit: bool = false # New variable to track if the player was hit

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
	move_and_slide()

func _stand_state(delta: float) -> void:
	velocity.x = 0 # Stop horizontal movement
	state_timer += delta
	if state_timer >= STANDING_DURATION:
		print("STAND duration finished.")
		if is_player_in_range:
			print("Player still in range. Transitioning to CHARGE.")
			_change_state(State.CHARGE)
		else:
			print("Player not in range. Transitioning to CRAWL.")
			pivot.scale.x = -direction
			_change_state(State.CRAWL)

func _crawl_state(delta: float) -> void:
	velocity.x = direction * WALK_SPEED

	distance_traveled += WALK_SPEED * delta

	if distance_traveled >= WALK_DISTANCE:
		print("CRAWL distance reached. Reversing direction and transitioning to STAND.")
		distance_traveled = 0.0
		direction *= -1
		_change_state(State.STAND)

# Handles the CHARGE state logic.
func _charge_state(delta: float) -> void:
	velocity.x = 0 # Stop horizontal movement during charge
	state_timer += delta
	if state_timer >= CHARGE_DURATION:
		print("CHARGE duration finished. Transitioning to ATTACK.")
		_change_state(State.ATTACK)

	if player:
		pivot.scale.x = -sign(player.global_position.x - global_position.x)

# Handles the ATTACK state logic.
func _attack_state(delta: float) -> void:
	state_timer += delta
	velocity.x = sign(player.global_position.x - global_position.x) * ATTACK_SPEED

	if is_on_floor() and not has_jumped:
		velocity.y = JUMP_VELOCITY
		has_jumped = true
		print("ATTACK started. Jumping.")
		
	if state_timer >= ATTACK_DURATION:
		print("ATTACK duration finished. Checking for player hit.")
		if player_was_hit:
			print("Player was hit.")
			if is_player_in_range:
				print("Player still in range. Looping to STAND & CHARGE.")
				_change_state(State.STAND)
			else:
				print("Player out of range. Transitioning to CRAWL.")
				_change_state(State.CRAWL)
		else:
			print("Player avoided the attack. Transitioning to VULNERABLE.")
			_change_state(State.VULNERABLE)

func _vulnerable_state(delta: float) -> void:
	velocity.x = 0 # Stop horizontal movement
	state_timer += delta
	if state_timer >= VULNERABLE_DURATION:
		print("VULNERABLE duration finished.")
		if is_player_in_range:
			print("Player still in range. Transitioning to CHARGE.")
			_change_state(State.CHARGE)
		else:
			print("Player not in range. Transitioning to STAND.")
			_change_state(State.STAND)

func _change_state(new_state) -> void:
	current_state = new_state
	state_timer = 0.0
	has_jumped = false # Reset jump flag on state change
	player_was_hit = false # Reset hit flag on state change

	match current_state:
		State.STAND:
			hurt_box.set_deferred("monitoring", false)
			hit_box.set_deferred("monitoring", false)
			hurt_box.set_deferred("monitorable", false)
			hit_box.set_deferred("monitorable", false)
			sprite_2d.play("stand")
		State.CRAWL:
			hurt_box.set_deferred("monitoring", false)
			hit_box.set_deferred("monitoring", false)
			hurt_box.set_deferred("monitorable", false)
			hit_box.set_deferred("monitorable", false)
			sprite_2d.play("crawl")
		State.CHARGE:
			hurt_box.set_deferred("monitoring", false)
			hit_box.set_deferred("monitoring", false)
			hurt_box.set_deferred("monitorable", false)
			hit_box.set_deferred("monitorable", false)
			sprite_2d.play("charge")
		State.ATTACK:
			hurt_box.set_deferred("monitoring", false)
			hit_box.set_deferred("monitoring", true)
			hurt_box.set_deferred("monitorable", false)
			hit_box.set_deferred("monitorable", true)
			sprite_2d.play("attack")
		State.VULNERABLE:
			hurt_box.set_deferred("monitoring", true)
			hit_box.set_deferred("monitoring", false)
			hurt_box.set_deferred("monitorable", true)
			hit_box.set_deferred("monitorable", false)
			sprite_2d.play("vulnerable")

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body == player:
		is_player_in_range = true
		print("Player entered detection area.")
		if current_state == State.STAND or current_state == State.CRAWL:
			print("Player detected, not in a locked state. Transitioning to CHARGE.")
			_change_state(State.CHARGE)

func _on_player_detector_body_exited(body: Node2D) -> void:
	if body == player:
		is_player_in_range = false
		print("Player exited detection area")

func take_damage(damage: float) -> void:
	enemy_health -= damage
	animation_player.play("hurt")
	print("Beetle Health: ", enemy_health)
	if enemy_health <= 0:
		print("Beetle defeated! Queueing free.")
		queue_free()

func _on_hit_box_area_entered(area) -> void:
	if current_state == State.ATTACK:
		if area.owner.is_in_group("player"):
			print("*** PLAYER'S HURTBOX WAS HIT ***")
			player_was_hit = true
			GameManager.take_damage(10.0)
			player._on_hurt_box_area_entered(null)
