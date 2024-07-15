class_name SceneTransitionArea
extends Area2D

var current_scene_file_path: String
@export var target_scene_index: int = 0 # Label in GUI to match target
var target_scene_label: Label

func _ready():
	self.body_entered.connect(_on_body_entered)
	
	current_scene_file_path = $"../..".scene_file_path.get_file()
	target_scene_label = $TargetSceneLabel
	target_scene_label.text = GameManager.get_target_scene_level_name(current_scene_file_path, target_scene_index)


func _on_body_entered(_body: Node2D):
	# TODO => REFACTOR
	# this requires parent(parent()) to be root node, too stringent
	GameManager.load_target_scene_level(current_scene_file_path, target_scene_index)
