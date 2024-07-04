class_name SceneTransitionArea
extends Area2D

@export var target_scene_index: int = 0 # Label in GUI to match target


func _ready():
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node2D):
	# TODO => REFACTOR
	# this requires parent(parent()) to be root node, too stringent
	var current_scene_file = $"../..".scene_file_path.get_file()
	GameManager.load_target_scene_level(current_scene_file, target_scene_index)
