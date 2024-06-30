extends Label
"""
const FONT_SIZE = 50

var fps_label_settings: LabelSettings

func _ready():
	fps_label_settings = LabelSettings.new()	# Instantiate label settings for fps label
	fps_label_settings.set_font_size(FONT_SIZE)	# Make it big
	fps_label_settings.font_color = Color.RED
	label_settings = fps_label_settings # Set to new obj as LabelSettings were null
"""

func _process(_delta):
	#var fps = Engine.get_frames_per_second()
	text = "\nCoins: %d" % GameManager.player_coin_count

