extends Node

@export var initial_coin_count: int = 0
@export var max_fps: int = 60
@export var physics_ticks_per_second: int = 60
var level_transition_map: Dictionary

const DEATH_DURATION: float = 1.0

var player_coin_count: int


func _init():
	player_coin_count = initial_coin_count

func _ready():
	level_transition_map = {
		"level_0.tscn": ["level_1.tscn"],
		"level_1.tscn": ["level_2.tscn"],
		"level_2.tscn": ["level_3.tscn"],
		}
	Engine.max_fps = max_fps
	Engine.physics_ticks_per_second = physics_ticks_per_second

func increment_coin_count():
	player_coin_count += 1

func reset_coin_count():
	player_coin_count = initial_coin_count


func get_target_scene_level_name(cur_scene: String, target_idx: int) -> String:
	return level_transition_map[cur_scene][target_idx]


func load_target_scene_level(cur_scene: String, target_idx: int):
	var target_scene_level: String = level_transition_map[cur_scene][target_idx]
	get_tree().change_scene_to_file("scenes/" + target_scene_level)


func die():
	Engine.time_scale = 1.0
	reset_coin_count()
	get_tree().reload_current_scene()
