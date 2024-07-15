extends Node2D

const S = 1

@onready var en: CharacterBody2D = $EnemyBrute

func _physics_process(_delta):
	if Input.is_anything_pressed():
		if Input.is_key_pressed(KEY_1):
			#print(en)
			var coll_poly: CollisionPolygon2D = en.get_child(1)
			print(coll_poly.polygon)
			pass
		if Input.is_key_pressed(KEY_2):
			pass
