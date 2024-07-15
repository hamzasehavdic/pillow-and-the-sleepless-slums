class_name KillArea
extends Area2D


func _ready():
	# map coll layer and mask
	collision_layer |= 1 << 5 # is hazard
	collision_mask |= 1 << 1 # touch player
	collision_mask |= 1 << 4 # touch enemy

func _physics_process(_delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("hurtable"):
			body.hurt()
			if body.has_method("set_modulate"):
				body.modulate = Color.BLACK
			if body is Player:
				Engine.time_scale = 0.1

