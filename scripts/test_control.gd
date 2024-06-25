extends Control

var output_label: Label

func _ready():
	# Set up the Control node
	anchor_right = 1
	anchor_bottom = 1

	# Create a label to display the output
	output_label = Label.new()
	output_label.anchor_right = 1
	output_label.anchor_bottom = 1
	output_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	output_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	output_label.text = "Move your mouse here and test buttons"

	add_child(output_label)

func _input(event):
	if event is InputEventMouseButton:
		output_label.text = "Button pressed: " + str(event.button_index) + "\n"
		output_label.text += "Is pressed: " + str(event.pressed) + "\n"
		output_label.text += "Double click: " + str(event.double_click)
	elif event is InputEventMouseMotion:
		if event.button_mask > 0:
			output_label.text = "Mouse motion with button(s) held:\n"
			output_label.text += "Button mask: " + str(event.button_mask)

	# Prevent the event from propagating further
	get_viewport().set_input_as_handled()
