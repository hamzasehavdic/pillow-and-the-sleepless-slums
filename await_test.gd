extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var label = $Label

func _ready():
    demonstrate_await()

func demonstrate_await():
    print("Starting demonstration")
    label.text = "Starting..."
    
    print("Playing animation 1")
    label.text = "Playing animation 1"
    sprite.play("animation1")
    await sprite.animation_finished
    print("Animation 1 finished")
    
    print("Playing animation 2")
    label.text = "Playing animation 2"
    sprite.play("animation2")
    await sprite.animation_finished
    print("Animation 2 finished")
    
    print("Demonstration complete")
    label.text = "Completed!"

func _process(_delta):
    if Input.is_action_just_pressed("ui_accept"):
        print("Button pressed!")
        label.text = "Button pressed!"
