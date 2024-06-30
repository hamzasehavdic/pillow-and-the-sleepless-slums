class_name Player
extends CharacterBody2D

enum State { IDLE, MOVING, JUMPING, JUMPSQUAT, FALLBRACE, FALLING, LANDING, MELEE, BOOSTED, DASHING, DEATH }

@onready var state_names: Dictionary = {0:"idle", 1:"moving", 2:"jumping", 3:"jumpsquat", 4:"fallbrace", 5:"falling", 6:"landing", 7:"melee", 8:"boosted", 9:"dashing", 10:"death"}

# (Independent) Member variables
var current_state: State
var boost_velocity: Vector2
var boost_timer: float
var last_dir: float
var can_air_dash: bool
var is_dash_jump: bool
@export var jump_accel_multiplier: float
@export var fall_deaccel_multiplier: float

# Constants
const GRAVITY: float = 900.0
const MOVE_SPEED: float = 100.0
const JUMP_FORCE: float = -300.0
const DASH_SPEED: float = 400.0

# Exported variables
@export var jump_sound: AudioStream = preload("res://assets/sounds/jump_1.wav")
@export var hurt_sound: AudioStream = preload("res://assets/sounds/hurt.wav")
@export var dash_sound: AudioStream = preload("res://assets/sounds/balloon_pop.wav")
@export var melee_sound: AudioStream = preload("res://assets/sounds/hit.wav")


# Dependent Node refs (to Nodes composed in/relate to Player)
var dash_timer: Timer
var sprite: AnimatedSprite2D
var sound_player: AudioStreamPlayer2D
var melee_hitbox: CollisionShape2D 
var state_label: Label


func _init():
	# Init any vars independent from scene tree
	current_state = State.FALLING
	boost_velocity = Vector2.ZERO
	boost_timer = 0.0
	last_dir = 1.0
	can_air_dash = false
	jump_accel_multiplier = 1.3
	fall_deaccel_multiplier = 0.8
	is_dash_jump = false


func _ready():
	# Init node refs & vars dependent on the scene tree
	dash_timer = $DashTimer
	sprite = $AnimatedSprite2D
	sound_player = $AudioStreamPlayer2D
	melee_hitbox = $MeleeHitboxArea2D/MeleeHitBoxCollisionShape2D
	state_label = $StateLabel


func _physics_process(delta: float) -> void:
	#print("State: ", current_state, "\nVel: ", velocity, "\nVel_b: ", boost_velocity, "\n")
	
	match current_state:
		State.IDLE:
			process_idle_state(delta)
		State.MOVING:
			process_moving_state(delta)
		State.JUMPING:
			process_jumping_state(delta)
		State.JUMPSQUAT:
			process_jumpsquat_state(delta)
		State.FALLBRACE:
			process_fallbrace_state(delta)
		State.FALLING:
			process_falling_state(delta)
		State.LANDING:
			process_landing_state(delta)
		State.MELEE:
			process_melee_state(delta)
		State.BOOSTED:
			process_boosted_state(delta)
		State.DASHING:
			process_dashing_state(delta)
	move_and_slide()
	transition_state()
	state_label.text = "State: " + state_names[current_state]


func process_idle_state(_delta: float) -> void:
	sprite.flip_h = last_dir < 0
	sprite.play("Idle")


func process_moving_state(_delta: float) -> void:
	apply_movement()
	sprite.flip_h = last_dir < 0
	sprite.play("Run")


func process_jumping_state(delta: float) -> void:
	apply_gravity(delta)
	apply_air_movement(2.0 if is_dash_jump else jump_accel_multiplier)
	sprite.play("Jump")


func process_jumpsquat_state(delta: float) -> void:
	apply_gravity(delta)
	apply_movement(0.1)
	if not sprite.is_playing() or sprite.animation != "JumpSquat":
		sprite.play("JumpSquat")
	if sprite.frame == sprite.sprite_frames.get_frame_count("JumpSquat") - 1:
		start_jump()


func process_fallbrace_state(delta: float) -> void:
	apply_gravity(delta)
	if not sprite.is_playing() or sprite.animation != "FallBrace":
		sprite.play("FallBrace")
	if sprite.frame == sprite.sprite_frames.get_frame_count("FallBrace") - 1:
		current_state = State.FALLING


func process_falling_state(delta: float) -> void:
	apply_gravity(delta)
	apply_air_movement(2.0 if is_dash_jump else fall_deaccel_multiplier)
	sprite.play("Fall")


func process_landing_state(_delta: float) -> void:
	apply_movement(0.1)
	if not sprite.is_playing() or sprite.animation != "Landing":
		sprite.play("Landing")
	if sprite.frame == sprite.sprite_frames.get_frame_count("Landing") - 1:
		land()


func process_melee_state(_delta: float) -> void:
	apply_movement(0.01)
	if not sprite.is_playing() or sprite.animation != "Melee":
		melee_hitbox.get_parent().position.x = 15 * (-1 if sprite.flip_h else 1)
		sprite.play("Melee")
	
	if sprite.frame > 8 and melee_hitbox.disabled:
		play_sound(melee_sound)
		melee_hitbox.disabled = false
	elif sprite.frame == sprite.sprite_frames.get_frame_count("Melee") - 1:
		melee_hitbox.disabled = true
		current_state = State.IDLE


func process_boosted_state(delta: float) -> void:
	boost_timer -= delta
	if boost_timer <= 0:
		boost_velocity = Vector2.ZERO
	else:
		velocity = boost_velocity
	sprite.play("Jump")


func process_dashing_state(_delta: float) -> void:
	apply_dash()
	sprite.self_modulate = Color.GREEN
	sprite.flip_h = last_dir < 0
	sprite.play("Dash")


func process_death_state() -> void:
	current_state = State.DEATH
	play_sound(hurt_sound)


func transition_state() -> void:
	# Note: player dash always turns to fall after timeout signal
	# Therefore, no need to transition
	match current_state:
		State.BOOSTED:
			if boost_velocity == Vector2.ZERO:
				velocity = Vector2.ZERO
				current_state = State.FALLING if not is_on_floor() else State.IDLE

			elif Input.is_action_just_pressed("dash") and can_air_dash:
				start_dash()

		State.IDLE, State.MOVING:
			# Change state
			if boost_velocity != Vector2.ZERO:
				current_state = State.BOOSTED

			elif Input.is_action_just_pressed("dash"):
				start_dash()

			elif not is_on_floor():
				current_state = State.FALLING

			elif Input.is_action_just_pressed("Melee"):
				current_state = State.MELEE

			elif Input.is_action_just_pressed("jump"):
				current_state = State.JUMPSQUAT
			# Loop current state
			elif Input.get_axis("move_left", "move_right") != 0:
				current_state = State.MOVING
			else:
				current_state = State.IDLE

		State.JUMPING, State.FALLING:
			if boost_velocity != Vector2.ZERO:
				current_state = State.BOOSTED

			elif Input.is_action_just_pressed("dash") and can_air_dash:
				start_dash()

			elif velocity.y == 0:
				if current_state == State.JUMPING:
					current_state = State.FALLBRACE
				elif current_state == State.FALLING and is_on_floor():
					current_state = State.LANDING
					is_dash_jump = false
		State.DASHING:
			if Input.is_action_just_pressed("jump"):
				is_dash_jump = true
				start_jump(1.5)


func apply_gravity(delta: float) -> void:
	# Option 1: Varying rise and fall speed
	#var fall_mult: float = 1.0 if current_state == State.JUMPING else 1.3
	#velocity.y += GRAVITY * delta * fall_mult

	# Option 2: Same rise and fall speed
	velocity.y += GRAVITY * delta


func apply_movement(magnitude: float = 1.0) -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	velocity.x = input_dir * MOVE_SPEED * magnitude
	if input_dir != 0:
		last_dir = input_dir 


func apply_air_movement(air_control: float = 1.0) -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	velocity.x = input_dir * MOVE_SPEED * air_control 


func apply_boost(boost_vel: Vector2, boost_duration: float) -> void:
	boost_velocity = boost_vel
	boost_timer = boost_duration
	current_state = State.BOOSTED


func apply_dash() -> void:
	velocity = Vector2(last_dir * DASH_SPEED, 0) # slight offset upwards
	#velocity.x = last_dir * DASH_SPEED


func start_jump(magnitude: float = 1.0) -> void:
	current_state = State.JUMPING
	velocity.y = JUMP_FORCE * magnitude
	play_sound(jump_sound)


func start_dash() -> void:
	current_state = State.DASHING # Prevent transitions
	dash_timer.start()
	play_sound(dash_sound)
	can_air_dash = false


func land():
	velocity.x = 0
	can_air_dash = true # Reset air dash
	if Input.get_axis("move_left", "move_right") != 0: 
		current_state = State.MOVING 
	else:
		current_state = State.IDLE 


func _on_dash_timer_timeout():
	if is_on_floor():
		land()
	else:
		current_state = State.FALLING
	sprite.self_modulate = Color.WHITE


func play_sound(sound_stream: AudioStream) -> void:
	sound_player.stream = sound_stream
	sound_player.play()


func _on_melee_hitbox_area_2d_area_entered(area: Node2D) -> void:
	var enemy = area.get_parent()
	if enemy.is_in_group("Enemies"):
		enemy.set_process(false)
		var hit_stun_duration = 0.5
		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(enemy, "skew", rad_to_deg(PI/4), hit_stun_duration)
		tween.tween_property(enemy, "position",\
				enemy.position + Vector2(last_dir * randi_range(50, 100), randi_range(-50, -75)), hit_stun_duration) 
		tween.tween_property(enemy, "modulate", Color.BLACK, hit_stun_duration)
		await tween.finished
		if enemy != null:
			enemy.queue_free()
