class_name Player
extends CharacterBody2D


enum State { IDLE, MOVING, JUMPING, FALLING, BOOSTED, DASHING, DEATH }

# (Independent) Member variables
var current_state: State
var boost_velocity: Vector2
var boost_timer: float
var last_dir: float
var can_air_dash: bool

# Constants
const GRAVITY: float = 900.0
const MOVE_SPEED: float = 100.0
const JUMP_FORCE: float = -300.0
const DASH_SPEED: float = 275.0

# Exported variables
@export var jump_sound: AudioStream = preload("res://assets/sounds/jump_1.wav")
@export var hurt_sound: AudioStream = preload("res://assets/sounds/hurt.wav")
@export var dash_sound: AudioStream = preload("res://assets/sounds/balloon_pop.wav")


# Dependent Node refs (to Nodes composed in/relate to Player)
var dash_timer: Timer
var sprite: AnimatedSprite2D
var sound_player: AudioStreamPlayer2D


func _init():
	# Init any vars independent from scene tree
	current_state = State.FALLING
	boost_velocity = Vector2.ZERO
	boost_timer = 0.0
	last_dir = 1.0
	can_air_dash = false


func _ready():
	# Init node refs & vars dependent on the scene tree
	dash_timer = $DashTimer
	sprite = $AnimatedSprite2D
	sound_player = $AudioStreamPlayer2D


func _physics_process(delta: float) -> void:
	#print("State: ", current_state, "\nVel: ", velocity, "\nVel_b: ", boost_velocity, "\n")
	
	match current_state:
		State.IDLE:
			process_idle_state(delta)
		State.MOVING:
			process_moving_state(delta)
		State.JUMPING:
			process_jumping_state(delta)
		State.FALLING:
			process_falling_state(delta)
		State.BOOSTED:
			process_boosted_state(delta)
		State.DASHING:
			process_dashing_state(delta)
		State.DEATH: # Other obj kill player
			# They overwrite player state to death
			process_death_state()
	move_and_slide()
	transition_state()


func process_idle_state(delta: float) -> void:
	apply_gravity(delta)
	sprite.flip_h = last_dir < 0
	sprite.play("Idle")

func process_moving_state(delta: float) -> void:
	apply_gravity(delta)
	apply_movement()
	sprite.flip_h = last_dir < 0
	sprite.play("Run")

func process_jumping_state(delta: float) -> void:
	apply_gravity(delta)
	apply_air_movement(1.3) # accel vel in jump
	sprite.play("Jump")

func process_falling_state(delta: float) -> void:
	apply_gravity(delta)
	apply_air_movement(0.8) # de-accel vel in fall
	sprite.play("Fall")

func process_boosted_state(delta: float) -> void:
	boost_timer -= delta
	if boost_timer <= 0:
		boost_velocity = Vector2.ZERO
	else:
		velocity = boost_velocity
	sprite.play("Boost")

func process_dashing_state(_delta: float) -> void:
	apply_dash()
	sprite.self_modulate = Color.GREEN
	sprite.flip_h = last_dir < 0
	sprite.play("Boost")

func process_death_state() -> void:
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
			if boost_velocity != Vector2.ZERO:
				current_state = State.BOOSTED

			elif Input.is_action_just_pressed("dash"):
				start_dash()

			elif not is_on_floor():
				current_state = State.FALLING

			elif Input.is_action_just_pressed("jump"):
				current_state = State.JUMPING
				velocity.y = JUMP_FORCE
				play_sound(jump_sound)

			elif Input.get_axis("move_left", "move_right") != 0:
				current_state = State.MOVING

			else:
				current_state = State.IDLE

		State.JUMPING, State.FALLING:
			if boost_velocity != Vector2.ZERO:
				current_state = State.BOOSTED

			elif Input.is_action_just_pressed("dash") and can_air_dash:
				start_dash()

			elif velocity.y > 0:
				current_state = State.FALLING

			elif is_on_floor(): # handle landing... land on plat if still in jump
				land()


func apply_gravity(delta: float) -> void:
	# Option 1: Varying rise and fall speed
	#var fall_mult: float = 1.0 if current_state == State.JUMPING else 1.3
	#velocity.y += GRAVITY * delta * fall_mult

	# Option 2: Same rise and fall speed
	velocity.y += GRAVITY * delta

func apply_movement() -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	velocity.x = input_dir * MOVE_SPEED
	if input_dir != 0:
		last_dir = input_dir 


func apply_air_movement(air_control: float) -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	velocity.x = input_dir * MOVE_SPEED * air_control 


func apply_boost(boost_vel: Vector2, boost_duration: float) -> void:
	boost_velocity = boost_vel
	boost_timer = boost_duration
	current_state = State.BOOSTED


func apply_dash() -> void:
	velocity = Vector2(last_dir * DASH_SPEED, 0) # slight offset upwards
	#velocity.x = last_dir * DASH_SPEED

func start_dash() -> void:
	current_state = State.DASHING # Prevent transitions
	dash_timer.start()
	play_sound(dash_sound)
	can_air_dash = false


func land():
	velocity.x = 0
	if Input.get_axis("move_left", "move_right") != 0: 
		current_state = State.MOVING 
	else:
		current_state = State.IDLE 
	can_air_dash = true # Reset air dash


func _on_dash_timer_timeout():
	if is_on_floor():
		land()
	else:
		current_state = State.FALLING
	sprite.self_modulate = Color.WHITE


func play_sound(sound_stream: AudioStream) -> void:
	sound_player.stream = sound_stream
	sound_player.play()


