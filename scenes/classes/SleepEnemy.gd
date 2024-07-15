class_name SleepEnemy
extends CharacterBody2D

var is_awake: bool

func snooze() -> void:
	is_awake = false
