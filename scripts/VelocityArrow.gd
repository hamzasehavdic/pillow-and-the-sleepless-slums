extends Node2D

# Make its own scene to reuse for NPC characters

@export var line_width: float = 2.0
@export var scale_factor: float = 0.1

@onready var character_body = get_parent()


func _process(_delta):
	queue_redraw() # Call _draw() foreach rendered frame


func _draw(): # Override draw functionality
	if character_body is CharacterBody2D: # Safety Check
		var velocity = character_body.velocity
		var end_point = velocity * scale_factor
		
		var line_color: Color
		if character_body.is_on_floor(): line_color = Color.GREEN
		else: line_color = Color.RED

		draw_line(Vector2.ZERO, end_point, line_color, line_width)

