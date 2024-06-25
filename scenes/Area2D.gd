class_name Booster
extends Area2D

#@export var boost_strength: float = 1.0
@export var boost_duration: float = 0.1 # Duration of the boost in seconds
@export var target_offset: Vector2 = Vector2(0, -30)

var velocity: Vector2

func _ready():
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	var magnitude_for_duration: float = 1 / self.boost_duration
	velocity = (-position + self.target_offset) * magnitude_for_duration
	#keep velocity as name for velocity arrow child


func calc_velocity() -> Vector2:
	return Vector2.ZERO # pass for now
	#var dir = Vector2(cos(deg_to_rad(boost_angle)), -sin(deg_to_rad(boost_angle)))
	#return dir.normalized() * self.boost_strength

func _on_body_entered(body: Node2D):
	print("Body entered: ", body.name)
	if body is Player:
		print("Player detected, applying boost")
		body.apply_boost(velocity, boost_duration)
	else:
		print("Non-player body detected: ", body.get_class())

