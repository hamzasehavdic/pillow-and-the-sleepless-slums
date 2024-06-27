extends Node2D

var player_in_area = false
@export var sprite: Sprite2D 
@onready var interaction_area: Area2D = $InteractionArea
@onready var interaction_display_box: TextureRect = $InteractionDisplayBox

func _ready():
	interaction_display_box.set_visible(false)
	interaction_area.connect("body_entered", Callable(self, "_show_InteractionArea_on_body_entered"))
	interaction_area.connect("body_exited", Callable(self, "_show_InteractionArea_on_body_exited"))


func _show_InteractionArea_on_body_entered(_body: Node2D):
	player_in_area = true
	interaction_display_box.set_visible(player_in_area)

func _show_InteractionArea_on_body_exited(_body: Node2D):
	player_in_area = false
	interaction_display_box.set_visible(player_in_area)


