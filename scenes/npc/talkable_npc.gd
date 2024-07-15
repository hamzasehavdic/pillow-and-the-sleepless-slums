extends Node2D

var is_talking: bool = false
@onready var player_in_area: bool = false
@onready var sprite: Sprite2D = $NpcSprite
@onready var interaction_area: Area2D = $InteractionArea
@onready var interaction_display_box: TextureRect = $InteractionDisplayBox
@onready var lines: Dialog = $NpcDialog
@onready var lines_label: Label = $NpcDialogLabel


signal interact

func _ready():
	interaction_display_box.set_visible(false)
	interaction_area.body_entered.connect(_open_InteractionArea_on_body_entered)
	interaction_area.body_exited.connect(_close_InteractionArea_on_body_exited)
	self.interact.connect(_talk_to_player)

func _process(_delta: float) -> void:
	if player_in_area and Input.is_action_just_pressed("interact") and not is_talking:
		interact.emit()

func _open_InteractionArea_on_body_entered(_body: Player):
	# Face player depending on where he is
	sprite.flip_h = true if (_body.position.x <= position.x) else false
	player_in_area = true
	interaction_display_box.set_visible(player_in_area)

func _close_InteractionArea_on_body_exited(_body: Player):
	player_in_area = false
	interaction_display_box.set_visible(player_in_area)

func _talk_to_player():
	interaction_display_box.set_visible(false)
	is_talking = true

	var npc_va_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	npc_va_player.volume_db = 10
	add_child(npc_va_player)

	for line in lines.dialog_lines:
		lines_label.text = line.dialog_text
		npc_va_player.stream = line.dialog_WAV_file
		npc_va_player.play()
		await npc_va_player.finished
		await get_tree().create_timer(1).timeout # Create x-sec timer between
		lines_label.text = ""
	
	interaction_display_box.set_visible(true)
	is_talking = false

