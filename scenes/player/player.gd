class_name Player
extends CharacterBody2D

enum State { IDLE, MOVING, JUMPING, JUMPSQUAT, FALLING, MELEE, DASHING, DEATH }

@onready var state_names: Dictionary = {0:"idle", 1:"moving", 2:"jumping", 3:"jumpsquat", 4:"falling", 5:"melee", 6:"dashing", 7:"death"}

# (Independent) Member variables
var current_state: State
var last_dir: float
var can_coyote_jump: bool
var can_air_dash: bool
var is_dash_jump: bool

# Constants
const GRAVITY: float = 900.0
const MOVE_SPEED: float = 150.0
const JUMP_FORCE: float = -300.0
const AIR_CONTROL: float = 1.3
const COYOTE_JUMP_WINDOW_DURATION: float = 3.0
const DASH_SPEED: float = 100.0
const DASH_DURATION: float = 0.3
const DASH_ACCEL: float = 1.3

# Exported variables
@export var jump_sound: AudioStream = preload("res://assets/audio/sfx/jump_mid.wav")
@export var hurt_sound: AudioStream = preload("res://assets/audio/sfx/hurt.wav")
@export var dash_sound: AudioStream = preload("res://assets/audio/sfx/dash.wav")
@export var melee_sound: AudioStream = preload("res://assets/audio/sfx/hit.wav")


# Dependent Node refs (to Nodes composed in/relate to Player)
var coyote_jump_timer: Timer
var jump_charge_timer: Timer
var landing_ray: RayCast2D
var dash_timer: Timer
var dash_magnitude: float
var sprite: AnimatedSprite2D
var sound_player: AudioStreamPlayer2D
var melee_hitbox_area: Area2D
var melee_hitbox_shape: CollisionShape2D
var hurtbox: CollisionShape2D
var state_label: Label


func _init():
	# Init any vars independent from scene tree
	current_state = State.FALLING
	last_dir = 1.0
	can_coyote_jump = true
	can_air_dash = false
	is_dash_jump = false


func _ready():
	add_to_group("hurtable")

	# Init node refs & vars dependent on the scene tree
	dash_timer = Timer.new()
	add_child(dash_timer)
	dash_timer.one_shot = true
	dash_timer.autostart = false
	dash_timer.wait_time = DASH_DURATION
	dash_timer.timeout.connect(self._on_dash_timer_timeout)
	dash_magnitude = 1/DASH_DURATION

	coyote_jump_timer = Timer.new()
	add_child(coyote_jump_timer)
	coyote_jump_timer.one_shot = true
	coyote_jump_timer.autostart = false
	coyote_jump_timer.wait_time = COYOTE_JUMP_WINDOW_DURATION
	coyote_jump_timer.timeout.connect(self._on_coyote_jump_timer_timeout)

	jump_charge_timer = Timer.new()
	add_child(jump_charge_timer)
	jump_charge_timer.one_shot = true
	jump_charge_timer.autostart = false
	jump_charge_timer.wait_time = 0.5

	sound_player = AudioStreamPlayer2D.new()
	add_child(sound_player)
	sound_player.finished.connect(_on_audio_stream_player_2d_finished)

	sprite = $AnimatedSprite2D
	melee_hitbox_area = $HitArea2D
	melee_hitbox_area.body_entered.connect(_snooze_enemy)
	melee_hitbox_shape = $HitArea2D/HitCollisionShape2D

	state_label = $StateLabel
	hurtbox = $HurtCollisionShape2D
	landing_ray = $LandingRayCast2D


func _physics_process(delta: float) -> void:

	match current_state:
		State.IDLE:
			process_idle_state(delta)
		State.MOVING:
			process_moving_state(delta)
		State.JUMPING:
			process_jumping_state(delta)
		State.JUMPSQUAT:
			process_jumpsquat_state(delta)
		State.FALLING:
			process_falling_state(delta)
		State.MELEE:
			process_melee_state(delta)
		State.DASHING:
			process_dashing_state(delta)
	move_and_slide()
	transition_state()
	state_label.text = "State: " + state_names[current_state]


func process_idle_state(_delta: float) -> void:
	sprite.flip_h = last_dir < 0
	sprite.play("IDLE")


func process_moving_state(_delta: float) -> void:
	apply_movement()
	sprite.flip_h = last_dir < 0
	sprite.play("MOVING")


func process_jumping_state(delta: float) -> void:
	apply_gravity(delta)
	apply_air_movement(AIR_CONTROL)


func process_jumpsquat_state(_delta: float) -> void:
	velocity = Vector2.ZERO


func process_falling_state(delta: float) -> void:
	apply_gravity(delta)
	apply_air_movement(AIR_CONTROL)


func process_melee_state(_delta: float) -> void:
	apply_movement(0.01) # TODO required to keep player grounded; fix this
	if not sprite.is_playing() or sprite.animation != "MELEE":
		melee_hitbox_shape.position.x = last_dir*abs(melee_hitbox_shape.position.x)
		sprite.play("MELEE")
	
	if sprite.frame > 5 and melee_hitbox_shape.disabled:
		play_sound(melee_sound)
		melee_hitbox_shape.set_deferred("disabled", false)
		print(melee_hitbox_area.body_entered.get_object())
	elif sprite.frame == sprite.sprite_frames.get_frame_count("MELEE") - 1:
		melee_hitbox_shape.set_deferred("disabled", true)
		current_state = State.IDLE


func process_dashing_state(_delta: float) -> void:
	apply_dash()
	sprite.self_modulate = Color.GREEN
	sprite.flip_h = last_dir < 0


func process_death_state() -> void:
	current_state = State.DEATH
	if is_on_floor():
		sprite.play("DEATH")
	play_sound(hurt_sound)
	velocity.x = 0


func transition_state() -> void:
	# Note: player dash always turns to fall after timeout signal
	# Therefore, no need to transition
	match current_state:

		State.JUMPSQUAT:
			if Input.is_action_just_released("jump"):
				start_jump(get_jump_charge_scalar())
				jump_charge_timer.stop()

			elif Input.is_action_just_pressed("dash") and can_air_dash:
				start_dash()


		State.IDLE, State.MOVING:
			if Input.is_action_just_pressed("dash"):
				start_dash()

			elif not is_on_floor():
				start_fall()
				coyote_jump_timer.start()

			elif Input.is_action_just_pressed("Melee"):
				current_state = State.MELEE
	

			elif Input.is_action_pressed("jump"):
				start_jumpsquat()

			# Loop current state
			elif Input.get_axis("move_left", "move_right") != 0:
				current_state = State.MOVING
			else:
				current_state = State.IDLE

		State.JUMPING:
			if velocity.y > 0:
				start_fall()

			elif Input.is_action_just_pressed("dash") and can_air_dash:
				start_dash()
		
		State.FALLING:
			if Input.is_action_just_pressed("jump") and coyote_jump_timer.time_left > 0:
				start_jump(0.8)

			elif Input.is_action_just_pressed("dash") and can_air_dash:
				start_dash()
			
			elif is_on_floor():
				land()

			elif landing_ray.is_colliding():
				if not sprite.is_playing() or sprite.animation != "Landing":
					sprite.play("LANDING")

		State.DASHING:
			if Input.is_action_just_pressed("jump"):
				is_dash_jump = true
				start_jump(DASH_ACCEL)


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


func start_jumpsquat() -> void:
	jump_charge_timer.start()
	sprite.play("JUMPSQUAT")
	current_state = State.JUMPSQUAT	


func get_jump_charge_scalar() -> float:
	if jump_charge_timer.time_left == 0:
		sprite.self_modulate = Color.RED
		return 1.5 # taller than 4 units
	elif jump_charge_timer.time_left < 0.4:
		sprite.self_modulate = Color.YELLOW
		return 1.25 # taller than 3 units
	return 1


func start_jump(magnitude: float = 1.0) -> void:
	velocity.y = JUMP_FORCE * magnitude

	sprite.play("JUMP")
	current_state = State.JUMPING
	play_sound(jump_sound)


func _on_coyote_jump_timer_timeout() -> void:
	can_coyote_jump = false


func start_fall() -> void:
	sprite.play("FALL")
	current_state = State.FALLING


func start_dash() -> void:
	can_air_dash = false
	sprite.play("DASH")
	current_state = State.DASHING # Prevent transitions
	dash_timer.start()
	play_sound(dash_sound)


func apply_dash() -> void:
	velocity = Vector2(last_dir * DASH_SPEED * dash_magnitude, 0) # slight offset upwards


func _on_dash_timer_timeout() -> void:
	if is_on_floor():
		land()
	else:
		current_state = State.FALLING
	sprite.self_modulate = Color.WHITE


func land() -> void:
	sprite.self_modulate = Color.WHITE
	velocity.x = 0
	can_air_dash = true # Reset air dash
	coyote_jump_timer.stop()
	if Input.get_axis("move_left", "move_right") != 0: 
		current_state = State.MOVING 
	else:
		current_state = State.IDLE


func hurt() -> void:
	process_death_state()


func _snooze_enemy(body) -> void:
	if body is SleepEnemy:
		body.snooze()


func play_sound(sound_stream: AudioStream) -> void:
	sound_player.stream = sound_stream
	sound_player.play()


func _on_audio_stream_player_2d_finished() -> void:
	if sound_player.stream == hurt_sound:
		GameManager.die()
