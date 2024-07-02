extends Area2D


@export var blastoff_magnitude = 100


func _on_body_entered(body: Node2D):
	body.process_death_state()
	
	Engine.time_scale = 0.1
	body.get_node("CollisionShape2D").queue_free()

	body.modulate = Color.RED
	body.velocity = Vector2.ZERO
	
	if not body.is_on_floor():	
		var tween = create_tween()
		tween.tween_property(
			body, "position:y",
			body.position.y - blastoff_magnitude, GameManager.DEATH_DURATION)






