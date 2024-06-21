extends Node

var player_score: int
var game_settings: Dictionary


func increase_score(amount):
	player_score += amount

func _ready():
	Engine.max_fps = 60
	player_score = 0
	game_settings = {
		"volume": 50,
		"difficulty": "normal"
	}
