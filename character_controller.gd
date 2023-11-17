extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const CHARGE_JUMP_VELOCITY = -800.0
const MAX_JUMPS = 1
const PUSH_FORCE = 50.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var default_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity = default_gravity
var jumps = 0
var jump_charge_timer = 0
var double_tap_timer = 0
var dashing = false
var dash_timer = 0
var dash_dir
var facing_dir = 1

var climbing = false
var ceiling_walk = false

@onready var animation_tree = $AnimationTree


func _ready():
	animation_tree.set_active(true)

func _process(delta):
	update_animation()


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta * 1.5
	else:
		jumps = MAX_JUMPS
#		if Input.is_action_pressed("ui_accept"):
#			jump_charge_timer = delta

	# Handle Jump.
	# Charge jump 
	if jump_charge_timer > 0:
		jump_charge_timer += delta;
		if jump_charge_timer > 2:
			$Sprite2D.modulate = Color('GREEN')
		if Input.is_action_just_released("ui_accept"):
			$Sprite2D.modulate = Color('WHITE')			
			if jump_charge_timer > 1.5:
				velocity.y = CHARGE_JUMP_VELOCITY
			else:
				velocity.y = JUMP_VELOCITY
			jump_charge_timer = 0
	
	if Input.is_action_just_pressed("ui_accept") and jumps:
		if is_on_ceiling():
			ceiling_walk = false
			$Sprite2D.flip_v = false
			velocity.y = -1 * JUMP_VELOCITY
			gravity = default_gravity
		if is_on_floor() and abs(velocity.x) <= 20:
			jump_charge_timer = delta
		else:
			jumps -= 1
			velocity.y = JUMP_VELOCITY
			
	if double_tap_timer > 0:
		double_tap_timer += delta
	
	
	if dash_timer > 0:
		dash_timer += delta
		
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		if is_on_floor():
			if double_tap_timer == 0:
				dash_dir = Input.get_axis("ui_left", "ui_right")
				double_tap_timer += delta
			elif double_tap_timer < 0.4 and dash_dir == Input.get_axis("ui_left", "ui_right"):
				dashing = true
				dash_timer += delta
			else:
				double_tap_timer = 0
			
	if is_on_ceiling():
		if Input.get_axis("ui_up", "ui_down") < 0 and not ceiling_walk:
			$Sprite2D.flip_v = true
			climbing = false
			ceiling_walk = true
			gravity = -1 * default_gravity
	elif not is_on_ceiling() and ceiling_walk and not is_above_grabbable(50.0):
		$Sprite2D.flip_v = false
		ceiling_walk = false
		gravity = default_gravity
		
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var horizontal_direction = Input.get_axis("ui_left", "ui_right")
	var vertical_direction = Input.get_axis("ui_up", "ui_down")
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		if is_above_grabbable(1500):
			climbing = true
		
	if vertical_direction and climbing:
		gravity = 0
		velocity.y = vertical_direction * SPEED * 2
	elif climbing:
		gravity = default_gravity
		climbing = false

#	if horizontal_direction < 0 or (dashing and dash_dir < 0):
#		$Sprite2D.flip_h = true
#		if $Sprite2D.offset.x > 0:
#			$Sprite2D.offset = $Sprite2D.offset * -1
#	elif horizontal_direction > 0 or (dashing and dash_dir > 0):
#		$Sprite2D.flip_h = false
#		if $Sprite2D.offset.x < 0:
#			$Sprite2D.offset = $Sprite2D.offset * -1

	if (horizontal_direction or dashing) and not climbing:
		
		if dashing:
			gravity = 0
			horizontal_direction = dash_dir * 3
			dash_timer += delta
			if dash_timer > 1:
				dash_dir = 0
				dash_timer = 0
				dashing = false
				gravity = default_gravity

		if jump_charge_timer > 0:
			horizontal_direction = horizontal_direction / 2.0
		velocity.x = horizontal_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * PUSH_FORCE)


func is_above_grabbable(check_distance):
	var grabbable = false
	var ray = RayCast2D.new()
	var vector_dir = Vector2(0, -1 * check_distance)
	ray.target_position = vector_dir
	add_child(ray)
	ray.force_raycast_update()
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider.is_in_group("grabbable"):
			grabbable = true
	ray.queue_free()
	return grabbable

func update_animation():
	var is_on_surface = is_on_floor() or is_on_ceiling()
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()

	if input_vector.x:
		facing_dir = input_vector.x
		animation_tree["parameters/Idle/blend_position"] = input_vector.x
		animation_tree["parameters/Landing/blend_position"] = input_vector.x
		animation_tree["parameters/Walking/blend_position"] = input_vector.x
		animation_tree["parameters/Crouching/blend_position"] = input_vector.x

	if not is_on_surface:
		animation_tree["parameters/conditions/is_jumping_falling"] = true
		animation_tree["parameters/JumpingFalling/blend_position"] = Vector2(facing_dir, velocity.normalized().y)
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_walking"] = false
		animation_tree["parameters/conditions/is_crouching"] = false
		return
		
	if jump_charge_timer > 0:
		animation_tree["parameters/conditions/is_crouching"] = true
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_walking"] = false
		animation_tree["parameters/conditions/is_jumping_falling"] = false
		return
		
	
	if animation_tree["parameters/conditions/is_jumping_falling"] == true and is_on_surface:
		animation_tree["parameters/conditions/is_landing"] = true
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_walking"] = false
		animation_tree["parameters/conditions/is_jumping_falling"] = false
		return
		
	if not input_vector.x and is_on_surface:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_landing"] = false
		animation_tree["parameters/conditions/is_walking"] = false
		animation_tree["parameters/conditions/is_crouching"] = false
		animation_tree["parameters/conditions/is_jumping_falling"] = false
		return

	if input_vector.x and is_on_surface:
		animation_tree["parameters/conditions/is_walking"] = true
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_landing"] = false
		animation_tree["parameters/conditions/is_crouching"] = false
		animation_tree["parameters/conditions/is_jumping_falling"] = false
		return
