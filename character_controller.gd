extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const CHARGE_JUMP_VELOCITY = -800.0
const MAX_JUMPS = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumps = 0
var jump_charge_timer = 0


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta * 1.5
	else:
		jumps = MAX_JUMPS
#		if Input.is_action_pressed("ui_accept"):
#			jump_charge_timer = delta

	# Handle Jump.
	
	if Input.is_action_just_pressed("ui_accept") and jumps:
		if is_on_floor() and abs(velocity.x) <= 20:
			jump_charge_timer = delta
		else:
			jumps -= 1
			velocity.y = JUMP_VELOCITY
			
	if jump_charge_timer > 0:
		jump_charge_timer += delta;
		if jump_charge_timer > 2:
			$Sprite2D.modulate = Color('GREEN')
		if Input.is_action_just_released("ui_accept"):
			$Sprite2D.modulate = Color('WHITE')			
			if jump_charge_timer > 2:
				velocity.y = CHARGE_JUMP_VELOCITY
			else:
				velocity.y = JUMP_VELOCITY
			jump_charge_timer = 0


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		if direction < 0:
			$Sprite2D.flip_h = true
		else:
			$Sprite2D.flip_h = false			
		if jump_charge_timer > 0:
			direction = direction / 2.0
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
