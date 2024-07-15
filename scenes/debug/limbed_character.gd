extends CharacterBody2D


class Limb:
    var body: AnimatableBody2D
    var state: String = "idle"
    var target_position: Vector2

    func _init(node: AnimatableBody2D):
        body = node
        target_position = body.position

    func move_to(target: Vector2, speed: float):
        target_position = target
        var direction = (target_position - body.position).normalized()
        body.constant_linear_velocity = direction * speed

    func update(_delta: float):
        if body.position.distance_to(target_position) < 1:
            body.constant_linear_velocity = Vector2.ZERO


class Head:
    var body: AnimatableBody2D
    var rotation_speed: float = 2.0
    var target_rotation: float = 0

    func _init(node: AnimatableBody2D):
        body = node

    func look_at(target: Vector2):
        target_rotation = (target - body.global_position).angle()

    func update(delta: float):
        body.rotation = lerp_angle(body.rotation, target_rotation, rotation_speed * delta)


# class_name LimbedCharacterBody2D
@onready var main_body: CharacterBody2D = self
@onready var head: Head = Head.new($Head)
@onready var left_arm: Limb = Limb.new($LeftArm)
@onready var right_arm: Limb = Limb.new($RightArm)
@onready var left_leg: Limb = Limb.new($LeftLeg)
@onready var right_leg: Limb = Limb.new($RightLeg)

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var movement_speed = 100.0
var limbs = []

func _ready():
    limbs = [left_arm, right_arm, left_leg, right_leg]

func _physics_process(delta):
    # Apply gravity to main body
    if not is_on_floor():
        velocity.y += gravity * delta

    # Example: Move enemy left and right
    var direction = sin(Time.get_ticks_msec() / 1000.0)
    velocity.x = direction * movement_speed

    move_and_slide()

    # Update head to look at player (assuming there's a player node)
    if has_node("/root/World/Player"):  # Adjust this path as needed
        head.look_at(get_node("/root/World/Player").global_position)

    # Example: Move arms in a pattern
    var time = Time.get_ticks_msec() / 1000.0
    left_arm.move_to(Vector2(cos(time) * 50, sin(time) * 50), 100)
    right_arm.move_to(Vector2(cos(time + PI) * 50, sin(time + PI) * 50), 100)

    # Example: Move legs for walking
    var leg_offset = 30
    if is_on_floor():
        if direction > 0:
            left_leg.move_to(Vector2(-leg_offset, 0), 200)
            right_leg.move_to(Vector2(leg_offset, -20), 200)
        else:
            left_leg.move_to(Vector2(-leg_offset, -20), 200)
            right_leg.move_to(Vector2(leg_offset, 0), 200)

    # Update all limbs
    head.update(delta)
    for limb in limbs:
        limb.update(delta)
