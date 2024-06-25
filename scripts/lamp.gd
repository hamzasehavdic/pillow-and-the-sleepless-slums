extends Area2D

@onready var lamp_light: PointLight2D = $PointLight2D

signal turnoff_effect()

func _on_player_entered(_body: Player):
	if lamp_light.enabled == true:
		lamp_light.enabled = false
		turnoff_effect.emit()

