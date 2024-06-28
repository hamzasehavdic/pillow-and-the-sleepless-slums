class_name GameManager
extends Node

var player_score: int
var game_settings: Dictionary


func increase_score(amount):
	player_score += amount

func _init():
	self.player_score = 0

func _ready():
	Engine.set_max_fps(60)
	Engine.set_physics_ticks_per_second(60)
