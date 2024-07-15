extends SleepEnemy


const SPEED = 50.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var curr_dir: int
var is_hurt: bool

var walk_timer: Timer
var idle_timer: Timer
var hurt_timer: Timer

@onready var sprite: Sprite2D = $BodySprite2D
@onready var sight_ray: RayCast2D = $SightRayCast2D
@onready var l_arm = $LBruteArm
@onready var r_arm = $RBruteArm

func _init():
	curr_dir = 1
	is_awake = true

func _ready():
	print("Enemy _ready called")
	l_arm = get_node_or_null("LBruteArm")
	r_arm = get_node_or_null("RBruteArm")

	if l_arm:
		print("Left arm found")
		l_arm.call_deferred("setup", -1)
	else:
		print("Left arm not found")

	if r_arm:
		print("Right arm found")
		r_arm.call_deferred("setup", 1)
	else:
		print("Right arm not found")
	get_tree().create_timer(1.5).timeout.connect(delayed_enemy_check)
	add_to_group("hurtable")
	setup_timers()
	#setup_arms()
	

func _physics_process(delta):
	if is_on_floor():
		if is_awake:
			if sight_ray.is_colliding():
				velocity.x = curr_dir * SPEED
			else:
				flip_dir()
		else:
			if hurt_timer.is_stopped():
				dream(delta)
			else:
				nightmare(delta)
	else:
		velocity.y += gravity * delta
	

	if Input.is_key_pressed(KEY_1):
		dream(delta)	
	if Input.is_key_pressed(KEY_2):
		nightmare(delta)
	move_and_slide()


func setup_timers() -> void:
	walk_timer = Timer.new()
	add_child(walk_timer)
	walk_timer.autostart = false
	walk_timer.one_shot = true
	walk_timer.wait_time = get_random_state_duration()
	walk_timer.timeout.connect(_on_walk_timeout)
	walk_timer.start()
	
	idle_timer = Timer.new()
	add_child(idle_timer)
	idle_timer.autostart = false
	idle_timer.one_shot = true
	idle_timer.timeout.connect(_on_idle_timeout)

	hurt_timer = Timer.new()
	add_child(hurt_timer)
	hurt_timer.autostart = false
	hurt_timer.one_shot = true
	hurt_timer.timeout.connect(_on_hurt_timeout)

func setup_arms() -> void:
	if l_arm and r_arm:
		l_arm.setup(-1)
		r_arm.setup(1)

func get_random_state_duration() -> int:
	return (RandomNumberGenerator.new()).randi_range(2, 10)

func flip_dir() -> void:
	sprite.flip_h = not sprite.flip_h
	sight_ray.target_position.x *= -1
	curr_dir = -1 if sprite.flip_h else 1

func _on_walk_timeout() -> void:
	idle_timer.wait_time = (RandomNumberGenerator.new()).randi_range(2, 10)
	idle_timer.start()

func _on_idle_timeout() -> void:
	walk_timer.wait_time = (RandomNumberGenerator.new()).randi_range(2, 10)
	walk_timer.start()

func _on_hurt_timeout() -> void:
	is_awake = true

func dream(delta: float) -> void:
	pass


func nightmare(delta: float) -> void:
	pass


func hurt() -> void:
	hurt_timer.start()

func delayed_enemy_check():
	print("Enemy delayed check")
	if l_arm:
		print("Left arm scale: ", l_arm.scale)
		print("Left arm global scale: ", l_arm.global_scale)
	if r_arm:
		print("Right arm scale: ", r_arm.scale)
		print("Right arm global scale: ", r_arm.global_scale)
	print("Enemy scale: ", scale)
