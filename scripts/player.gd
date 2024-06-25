class_name Player
extends CharacterBody2D


enum State { IDLE, MOVING, JUMPING, FALLING, BOOSTED }

var current_state: State = State.IDLE
var boost_velocity: Vector2 = Vector2.ZERO
var boost_timer: float = 0.0
var last_dir: float

@export var gravity: float = 900.0
@export var move_speed: float = 100.0
@export var jump_force: float = -300.0
@export var air_control: float = 1.0

@onready var sprite: AnimatedSprite2D = $"AnimatedSprite2D"
@onready var coin_count: int = 0


func _physics_process(delta: float) -> void:
	print("State: ", current_state, "\nDir: ", "\nVel: ", velocity, "\nVel_b: ", boost_velocity, "\n")
	
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
	
	move_and_slide()
	update_state()


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
	apply_air_movement()

func process_falling_state(delta: float) -> void:
	apply_gravity(delta)
	apply_air_movement()
	sprite.play("Fall")

func process_boosted_state(delta: float) -> void:
	boost_timer -= delta
	if boost_timer <= 0:
		boost_velocity = Vector2.ZERO
	else:
		velocity = boost_velocity
	sprite.play("Boost")


func update_state() -> void:
	match self.current_state:
		State.BOOSTED:
			if boost_velocity == Vector2.ZERO:
				velocity = Vector2.ZERO
				current_state = State.FALLING if not is_on_floor() else State.IDLE
		State.IDLE, State.MOVING:
			if boost_velocity != Vector2.ZERO:
				current_state = State.BOOSTED
			elif not is_on_floor():
				current_state = State.FALLING
			elif Input.is_action_just_pressed("jump"):
				current_state = State.JUMPING
				velocity.y = jump_force
			elif Input.get_axis("move_left", "move_right") != 0:
				current_state = State.MOVING
			else:
				current_state = State.IDLE
		State.JUMPING:
			if boost_velocity != Vector2.ZERO:
				current_state = State.BOOSTED
			elif velocity.y > 0:
				current_state = State.FALLING
			elif is_on_floor(): # handle landing... you can land on plat if youre still in jump
				land()
		State.FALLING:
			if boost_velocity != Vector2.ZERO:
				current_state = State.BOOSTED
			elif is_on_floor(): # handle landing
				land()

func apply_gravity(delta: float) -> void:
	self.velocity.y += gravity * delta

func apply_movement() -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	self.velocity.x = input_dir * self.move_speed
	if input_dir != 0:
		self.last_dir = input_dir 

func apply_air_movement() -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	self.velocity.x = input_dir * self.move_speed * self.air_control

func apply_boost(boost_vel: Vector2, boost_duration: float) -> void:
	self.boost_velocity = boost_vel
	self.boost_timer = boost_duration
	self.current_state = State.BOOSTED


func land():
	self.velocity.x = 0
	self.current_state = State.MOVING if Input.get_axis("move_left", "move_right") != 0 else State.IDLE 


func increment_coin_count():
	self.coin_count += 1

