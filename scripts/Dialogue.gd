extends Node2D

# Make Array where each elem is a Dict called DialogEntry
# DialogEntry key is a String to annotate Labels in a TextBox/TextureRect
# DialogEntry value is a AudioStream file (pref .wav) to be played during label is being rendered
@export var dialog_lines: Array[DialogEntry] = [DialogEntry.new()]

@onready var dialog_sound_player = $DialogStreamPlayer
@onready var dialog_text_box = $TextureRect
