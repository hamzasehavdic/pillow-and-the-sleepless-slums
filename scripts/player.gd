class_name Player
extends CharacterBody2D


const SPEED: float = 100.0
const JUMP_VELOCITY: float = -300.0


# Get the gravity from the project settings to be synced with RigidBody nodes
# Why: match player gravity to world gravity
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):

	print("VELOCITY VEC = ", velocity)
	print("POSITION ", position)
	
	# add gravity when airborne
	if not is_on_floor():
		velocity.y += gravity * delta

	# handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions 
	# with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	print("DIRECTION = ", direction)
	if direction:
		velocity.x = direction * SPEED * delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# Custom function to get axis input as an integer
# Why: Discretize movement, 
# preventing continous movements via analog stick
# making stick behave like button
func get_axis_int(negative_action: String, positive_action: String) -> int:
	var strength = Input.get_axis(negative_action, positive_action)
	if strength > 0:
		return 1
	elif strength < 0:
		return -1
	else:
		return 0


var inventory: Array = []
var health: int = 100

# Function to add item to inventory (using assertions)
func add_item_to_inventory(item: Item) -> void:
	#Assertion to ensure item has a valid name (development-time check)
	assert(item.name != "", "Item must have a valid name")
	inventory.append(item)
	assert(inventory.has(item), "Item must be added to inventory")
	print("Added %s to inventory" % item.name)

# Function to use item (using try-catch for runtime errors)
func use_item(item: Item) -> void:
	# Pre-conditonals before using item
	if not inventory.has(item):
		print("Error: Item is not in inventory")
		return
	if item.health_boost == 0:
		print("Item has no health boost value")
		return
	
	# Should have past pre-conditions, now use
	health += item.health_boost
	if health > 100:
		health = 100
		print("%s used, health is now %d" % [item.name, health])
	inventory.erase(item)
