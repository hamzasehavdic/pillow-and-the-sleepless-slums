extends Area2D

func _on_player_entered(body: Player):
	print("+1 coin")
	body.coin_count += 1
	queue_free()
