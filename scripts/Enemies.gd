extends Node

@onready var spectres: Array = self.get_children()
const SKEW_AMOUNT = PI/2 

func _on_lamp_turnoff_effect():
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	
	for spectre in spectres:
		tween.tween_property(spectre, "self_modulate:a", 0.1, 2)
		tween.tween_property(spectre, "skew", SKEW_AMOUNT, 1.8)
	await tween.finished
	self.queue_free()
	

	get_parent()\
	.get_node("Platforms")\
	.get_node("MovingPlatform")\
	.get_node("AnimationPlayer")\
	.play("RESET")


