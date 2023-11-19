extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const CHARGE_JUMP_VELOCITY = -800.0
const MAX_JUMPS = 1
const PUSH_FORCE = 10.0

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
#	if not is_on_floor():
	velocity.y += gravity * delta * 1.5
	
	if is_on_floor():
		jumps = MAX_JUMPS
#		if Input.is_action_pressed("jump"):
#			jump_charge_timer = delta

	# Charge jump 
	if Input.is_action_pressed("down") and is_on_floor():
		jump_charge_timer += delta;
		if jump_charge_timer > 1.5:
			$Sprite2D.modulate = Color('GREEN')
			if Input.is_action_just_pressed("jump"):
				velocity.y = CHARGE_JUMP_VELOCITY
				$Sprite2D.modulate = Color('WHITE')
				jump_charge_timer = 0
				jumps -=1
	else:
		$Sprite2D.modulate = Color('WHITE')
		jump_charge_timer = 0
	
	if Input.is_action_just_pressed("jump") and jumps:
		if ceiling_walk:
			ceiling_walk = false
			$Sprite2D.flip_v = false
			$Sprite2D.offset.y = 0
			$CollisionShape2D.position += Vector2(0,5)
			up_direction = Vector2(0, -1)
			gravity = default_gravity
			velocity.y = -1 * JUMP_VELOCITY
		else:
			jumps -= 1
			velocity.y = JUMP_VELOCITY
			
		
	if double_tap_timer > 0:
		double_tap_timer += delta
	
	
	if dash_timer > 0:
		dash_timer += delta
		
	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
		if is_on_floor() and not jump_charge_timer:
			if double_tap_timer == 0:
				dash_dir = Input.get_axis("left", "right")
				double_tap_timer += delta
			elif double_tap_timer < 0.5 and dash_dir == Input.get_axis("left", "right"):
				dashing = false
				dash_timer += delta
			else:
				double_tap_timer = 0
			
	if is_on_ceiling():
		if climbing and not ceiling_walk:
			$Sprite2D.flip_v = true
			$Sprite2D.offset.y = 10
			$CollisionShape2D.position -= Vector2(0,5)
			climbing = false
			ceiling_walk = true
			up_direction = Vector2(0, 1)
			gravity = -1 * default_gravity
	elif ceiling_walk and not is_above_grabbable(50.0):
		up_direction = Vector2(0, -1)
		$Sprite2D.flip_v = false
		$Sprite2D.offset.y = 0
		$CollisionShape2D.position += Vector2(0,5)
		
		ceiling_walk = false
		gravity = default_gravity
		
	

	# Get the input direction and handle the movement/deceleration.
	var horizontal_direction = Input.get_axis("left", "right")
	var vertical_direction = Input.get_axis("up", "down")
	if Input.is_action_just_pressed("up") and is_on_floor():
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
			#if you're charging a jump, don't walk
			horizontal_direction = 0
		velocity.x = horizontal_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		var collider = c.get_collider()
		if collider is RigidBody2D:
			collider.apply_central_impulse(-c.get_normal() * PUSH_FORCE)
		elif collider is CharacterBody2D:
			collider.velocity += -c.get_normal() * PUSH_FORCE*100


func is_above_grabbable(check_distance):
	var grabbable = false
	var ray = RayCast2D.new()
	var vector_dir = Vector2(0, -1 * check_distance)
	ray.target_position = vector_dir
	ray.collision_mask = 2
	add_child(ray)
	ray.force_raycast_update()
	if ray.is_colliding():
		grabbable = true
	ray.queue_free()
	return grabbable

func update_animation():
	var is_on_surface = is_on_floor() or is_on_ceiling()
	var input_vector = Input.get_vector("left", "right", "up", "down").normalized()

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
