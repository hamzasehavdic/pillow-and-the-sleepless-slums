extends Area2D

@onready var light_ray: RayCast2D = $LightRayCast2D
@export var light: Light2D
@onready var light_width: int = 10
@export var blastoff_magnitude = 50


signal turnoff_effect()

func _ready():
	light = Light2D.new.call()
	light.texture = create_light_texture()  # Or load a texture
	light.energy = 3.0
	light.shadow_enabled = true
	light_ray.add_child(light)

	self.body_entered.connect(_on_player_touch_switch)


func _process(delta):
	light_ray.rotation += 1 * delta

	if light_ray.is_colliding() and light_ray.get_collider() is Player:
		_on_player_entered_light_kill(light_ray.get_collider())


func _on_player_touch_switch(_body: Player):
	if light.enabled == true:
		light.enabled = false
		turnoff_effect.emit()


func create_light_texture() -> GradientTexture2D:
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color.RED)
	gradient.add_point(0.4, Color.YELLOW)  # Yellow at center
	gradient.add_point(1.0, Color(1, 1, 1, 1))  # Transparent at edge

	var texture = GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = light_width
	# light src is at center; needs 2* to makeup target len of ray
	texture.height = light_ray.target_position.y * 2
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2.ZERO
	texture.fill_to = Vector2.ONE

	return texture



func _on_player_entered_light_kill(body: Player):
	body.process_death_state()
	
	Engine.time_scale = 0.1
	body.get_node("CollisionShape2D").queue_free()
	body.modulate = Color.RED
	




