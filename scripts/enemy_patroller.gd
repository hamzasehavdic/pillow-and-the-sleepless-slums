extends Node2D


var dir: int
var speed: float

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast: RayCast2D = $RayCast2D

func _on_wakeup_animation_finished():
	speed = 30.0
	anim_sprite.play("idle")


func _ready():
	self.add_to_group("Enemies")
	speed = 0.0
	dir = 1
	anim_sprite.play("wakeup")


func _process(delta):
	if ray_cast.is_colliding():
		dir *= -1
		anim_sprite.flip_h = not anim_sprite.flip_h
		ray_cast.rotate(PI)

	self.position.x += dir * speed * delta
