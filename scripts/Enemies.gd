extends Node

@onready var enemies: Array = self.get_children()
const SKEW_AMOUNT = PI/2 

func _ready():
	%Lamp.turnoff_effect.connect(_on_lamp_turnoff_effect)

func _on_lamp_turnoff_effect():
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	
	for enemy in enemies:
		tween.tween_property(enemy, "self_modulate:a", 0.1, 2)
		tween.tween_property(enemy, "skew", SKEW_AMOUNT, 1.8)
	await tween.finished
	self.queue_free()
	
	%MovingPlatformAnimationPlayer.play("RESET")


