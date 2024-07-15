extends Node2D


var dir: int
var speed: float
@onready var sprite: Sprite2D = $Sprite2D
@onready var ray_cast: RayCast2D = $RayCast2D


func _ready():
	add_to_group("Enemies")
	speed = 30.0
	dir = 1


func _process(delta):
	if ray_cast.is_colliding():
		dir *= -1
		sprite.flip_h = not sprite.flip_h
		ray_cast.rotate(PI)

	position.x += dir * speed * delta
