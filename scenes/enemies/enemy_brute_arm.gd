extends CharacterBody2D

@export var arm_rotation_deg = 0.0
@onready var held_body: Node2D = null
@onready var arm_sprite: Sprite2D = $ArmSprite2D
@onready var fist_area: Area2D = $FistArea2D

func _ready():
	print("Arm _ready called")
	fist_area.monitoring = false
	fist_area.body_entered.connect(_on_touch)

	
func _process(_delta):
	move_and_slide()

	if Input.is_key_pressed(KEY_1):
		rest_arm()
	elif Input.is_key_pressed(KEY_2):
		raise_arm()
	elif Input.is_key_pressed(KEY_3):
		stretch_arm()
	elif Input.is_key_pressed(KEY_4):
		contract_arm()
	
	if held_body != null:
		held_body.global_position = fist_area.global_position


func setup(direction: int) -> void:
	print("Arm setup called with direction: ", direction)
	scale.x = direction * 0.25
	scale.y = 0.25
	print("Arm scale set to: ", scale)


func rest_arm() -> void:
	fist_area.monitoring = false
	if held_body != null:
		release_pulled_body(held_body)
		held_body = null
	var tween: Tween = create_tween()
	tween.tween_property(arm_sprite, "self_modulate", Color.WHITE, 0.1)
	tween.tween_property(self, "rotation_degrees", 0.0, 0.9)

func raise_arm() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(arm_sprite, "self_modulate", Color.BLUE, 0.1)
	tween.tween_property(self, "rotation_degrees", arm_rotation_deg, 0.9)


func stretch_arm() -> void:
	# assuming scale pty is unlocked
	fist_area.monitoring = true
	var tween: Tween = create_tween()
	tween.tween_property(arm_sprite, "self_modulate", Color.GREEN, 0.1)
	tween.tween_property(self, "scale:y", 1, 3.0)
	await tween.finished
	contract_arm()
	
func contract_arm() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(arm_sprite, "self_modulate", Color.RED, 0.1)
	tween.tween_property(self, "scale:y", 0.25, 3.0)
	await tween.finished
	rest_arm()


func _on_touch(body: Node2D) -> void:
	if held_body == null:
		fist_area.monitoring = false
		if body.is_in_group("hazards"):
			get_parent().hurt() # hurt brute reaction: jump?
		elif body.is_in_group("pullable"):
			pull(body)
		elif body.is_in_group("pushable"):
			push(body)

func pull(body: Node2D) -> void:
	if held_body == null:
		held_body = body
		body.get_parent().remove_child(body)
		add_child(body)

func release_pulled_body(held: Node2D) -> void:
	remove_child(held)
	# may not work;
	# assumes that body will fall w/ gravity
	# assumes that arms grandparent (brute parent) is the level
	# refactor given these assumptions
	# -> marker2d -> charbody2d -> level | Pulled
	$"../../../Pulled".add_child(held)
	held.global_position = fist_area.global_position


func push(body: Node2D) -> void:
	# vague but useable method name for pushable obj
	body.trigger_push_event()


