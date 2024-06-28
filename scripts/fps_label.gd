extends Label

const FONT_SIZE = 50


# Called when the node enters the scene tree for the first time.
func _ready():
	var fpsLabelSettings = LabelSettings.new()	# Instantiate label settings for fps label
	fpsLabelSettings.set_font_size(FONT_SIZE)	# Make it big
	fpsLabelSettings.font_color = Color.RED
	self.set_label_settings(fpsLabelSettings)	# Set to new obj as LabelSettings were null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var fps = Engine.get_frames_per_second()
	self.text = "FPS: " + str(fps)\
		+ "\nCoins: " + str($GameManager.player_coin_count)
