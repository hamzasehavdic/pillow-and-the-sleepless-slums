extends Node2D

func _process(_delta):
	$EnemyBrute.global_position = get_global_mouse_position()
