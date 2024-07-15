extends Node2D


var line_color: Color
@onready var parent = get_parent()
@export var line_width: float = 2.0
@export var scale_factor: float = 0.1 


func _process(_delta):
	queue_redraw() # Call _draw() foreach rendered frame


func _draw(): # Override draw functionality
	if parent is Player: # Safety Check
		if parent.is_on_floor():
			line_color = Color.GREEN
		else: 
			line_color = Color.RED
	elif parent is Booster:
		line_color = Color.PURPLE
		var booster: Booster = parent
		scale_factor = booster.boost_duration
	else:
		line_color = Color.BLUE

	var velocity = parent.velocity
	var end_point = velocity * scale_factor
	draw_line(Vector2.ZERO, end_point, line_color, line_width)

