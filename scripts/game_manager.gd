extends Node

@export var initial_coin_count: int = 0
@export var max_fps: int = 60
@export var physics_ticks_per_second: int = 60
const DEATH_DURATION: float = 1.0

var player_coin_count: int


func _init():
	player_coin_count = initial_coin_count

func _ready():
	Engine.max_fps = max_fps
	Engine.physics_ticks_per_second = physics_ticks_per_second

func increment_coin_count():
	player_coin_count += 1

func reset_coin_count():
	player_coin_count = initial_coin_count

func die():
	Engine.time_scale = 1.0
	reset_coin_count()
	get_tree().reload_current_scene()
