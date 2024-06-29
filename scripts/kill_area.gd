extends Area2D


@onready var timer = $Timer
@export var blastoff_magnitude = 50


func _on_body_entered(body: Node2D):
	body.process_death_state()
	
	Engine.time_scale = 0.5
	body.get_node("CollisionShape2D").queue_free()

	body.get_child(0).modulate = Color.RED
	
	if get_parent().is_in_group("Enemies"):
	# fix this to be away from enemy not towards enemy facing dir
		var enemy_dir = get_parent().dir
		body.rotate(enemy_dir * PI/8)
	
	var tween: Tween = create_tween()
	var local_up = Vector2.UP.rotated(body.rotation)
	print(local_up)
	tween.tween_property(
		body, "position",
		body.position + local_up * blastoff_magnitude, 0.5)

	timer.start()


func _on_timer_timeout():
	# Get the tree of nodes this kill area is in
	# Then reloads the entire scene (Main)
	Engine.time_scale = 1.0
	GameManager.reset_coin_count()
	get_tree().reload_current_scene()
