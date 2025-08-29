extends CharacterBody2D

const WALK_SPEED = 100.0
const ATTACK_DELAY = 1.0
const ATTACK_COUNT = 5
const REST_DURATION = 3.0
const DASH_SPEED = 500.0
const DASH_DISTANCE_THRESHOLD = 500.0
const DASH_DURATION = 0.5

const HEALTH_75_PERCENT = 75.0
const HEALTH_50_PERCENT = 50.0
const HEALTH_25_PERCENT = 25.0

enum State { WALK, ATTACK, REST, DEATH, DASH }

@onready var player = get_parent().find_child("player")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurt_box: Area2D = $HurtBox
@onready var hit_box: Area2D = $HitBox
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

var current_state = State.WALK
var boss_health = 100.0
var max_boss_health = 100.0
var attacks_done = 0

func _ready() -> void:
	hurt_box.area_entered.connect(_on_hurt_box_area_entered)
	animation_player.animation_finished.connect(_on_animation_finished)
	timer.timeout.connect(_on_timer_timeout)
	_change_state(State.WALK)

# Main physics loop for boss behavior
func _physics_process(delta: float) -> void:
	match current_state:
		State.WALK:
			_walk_to_player(delta)
		State.DASH:
			_dash_to_player(delta)
		State.ATTACK:
			# The attack state is handled by the timer and animation finished signal
			pass
		State.REST:
			# The rest state is handled by the timer
			pass
		State.DEATH:
			# The death state is currently empty, but can be expanded
			pass

func _walk_to_player(_delta: float) -> void:
	if is_instance_valid(player):
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player > DASH_DISTANCE_THRESHOLD:
			_change_state(State.DASH)
			return
			
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * WALK_SPEED
		move_and_slide()

		if direction.x > 0:
			animated_sprite.flip_h = true
		elif direction.x < 0:
			animated_sprite.flip_h = false

		animated_sprite.play("walk_100")

# Boss performs a dash towards the player
func _dash_to_player(_delta: float) -> void:
	if is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * DASH_SPEED
		move_and_slide()
		
		if direction.x > 0:
			animated_sprite.flip_h = true
		elif direction.x < 0:
			animated_sprite.flip_h = false

func _change_state(new_state) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	match current_state:
		State.WALK:
			# Reset attack counter when going back to walk state
			attacks_done = 0
			_set_hitboxes(false, false)
			# Stop any running timers
			timer.stop()
		State.DASH:
			_set_hitboxes(false, false)
			_play_animation_for_health_state("dash")
			timer.start(DASH_DURATION)
		State.ATTACK:
			# Disable hitboxes until the attack animation starts
			_set_hitboxes(true, false)
			timer.start(ATTACK_DELAY)
		State.REST:
			_set_hitboxes(true, false)
			animated_sprite.play("rest_100")
			timer.start(REST_DURATION)
		State.DEATH:
			_set_hitboxes(false, false)
			animated_sprite.play("death_100")

# Enable/disable hurtbox and hitbox
func _set_hitboxes(is_hurtbox_enabled: bool, is_hitbox_enabled: bool) -> void:
	hurt_box.set_deferred("monitoring", is_hurtbox_enabled)
	hurt_box.set_deferred("monitorable", is_hurtbox_enabled)
	hit_box.set_deferred("monitoring", is_hitbox_enabled)
	hit_box.set_deferred("monitorable", is_hitbox_enabled)

# Take damage and update health/animation
func take_damage(damage: float) -> void:
	boss_health -= damage
	boss_health = max(0, boss_health)
	
	print("Boss Health: " + str(boss_health))
	
	# Change animation based on health percentage
	var health_percent = (boss_health / max_boss_health) * 100.0
	
	if health_percent <= 0:
		_change_state(State.DEATH)
	elif health_percent <= HEALTH_25_PERCENT:
		_play_animation_for_health_state("25")
	elif health_percent <= HEALTH_50_PERCENT:
		_play_animation_for_health_state("50")
	elif health_percent <= HEALTH_75_PERCENT:
		_play_animation_for_health_state("75")

# Helper function to play the correct animation based on health
func _play_animation_for_health_state(health_suffix: String) -> void:
	match current_state:
		State.WALK:
			animated_sprite.play("walk_" + health_suffix)
		State.DASH:
			animated_sprite.play("dash_" + health_suffix)
		# Add other states here if they have health-dependent animations
		State.ATTACK:
			animated_sprite.play("attack_" + health_suffix)

# Handle the HurtBox being hit by a player's hitbox
func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		if area.owner.has_method("get_damage"):
			take_damage(area.owner.get_damage())
	
	# The hurt animation is handled by the animation_player's signal to prevent animation conflicts
	animation_player.play("hurt_100")

# Handle the timer timeout
func _on_timer_timeout() -> void:
	if current_state == State.ATTACK:
		_perform_attack()
	elif current_state == State.REST or current_state == State.DASH:
		_change_state(State.WALK)

# Perform a single attack
func _perform_attack() -> void:
	if attacks_done < ATTACK_COUNT:
		attacks_done += 1
		_play_attack_animation()
		timer.start(ATTACK_DELAY)
	else:
		_change_state(State.REST)

# Play the correct attack animation based on health
func _play_attack_animation() -> void:
	var health_percent = (boss_health / max_boss_health) * 100.0
	
	if health_percent <= HEALTH_25_PERCENT:
		animated_sprite.play("attack_25")
	elif health_percent <= HEALTH_50_PERCENT:
		animated_sprite.play("attack_50")
	elif health_percent <= HEALTH_75_PERCENT:
		animated_sprite.play("attack_75")
	else:
		animated_sprite.play("attack_100")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("hurt"):
		_change_state(State.WALK)
	elif anim_name.begins_with("attack"):
		_set_hitboxes(false, true)
	elif anim_name.begins_with("death"):
		queue_free()
