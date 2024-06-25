class_name Coin
extends Area2D

signal collected(collector)


func _physics_process(_delta):
	check_for_collision()


func check_for_collision():
	#var start_time = Time.get_ticks_usec()

	var space_state = get_world_2d().direct_space_state

	var query = PhysicsShapeQueryParameters2D.new()

	query.set_shape($CoinCollisionShape2D.shape)


	query.transform = global_transform

	var result = space_state.intersect_shape(query)
	#print(result) # see array of colliders in coin

	for collision in result:
		var collider = collision["collider"]

		#print("Col mask: ", collider.collision_mask)
		#print("Col layer: ", collider.collision_layer)
		#print("Coin mask: ", self.collision_mask)
		#print("Coin layer: ", self.collision_layer)

		#collected.emit(collector) # no point emitting unless need for sep concerns
		
		#if collider.is_in_group("Player"): # group membership lookup, slow but flex
		#if (self.collision_mask == collider.collision_layer): # mask and layer approach
		if collider is Player: # direct type check approach
			on_collected(collider)

	#var end_time = Time.get_ticks_usec()
	#print(end_time - start_time / 1000.0)


func on_collected(collector: Player):
	collector.increment_coin_count()
	queue_free()
