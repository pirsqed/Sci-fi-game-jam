extends CharacterBody2D


const SPEED = 300.0
const SMALL_HOP = -300.0
const BIG_HOP = -500.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var random_timer = 0

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_on_floor():
		velocity = Vector2.ZERO
		random_timer -= delta
		if random_timer <= 0:
			random_timer = randf_range(0.2, 2)
			var random_vector = Vector2.from_angle(randf_range(PI*0.25, PI*0.75))
			var random_magnitude = randf_range(SMALL_HOP, BIG_HOP)
			var random_jump_vector = random_vector * random_magnitude
			if is_on_wall():
				var wall_normal = get_wall_normal()
				print(wall_normal)
			velocity = random_jump_vector
			var facing = velocity.normalized().x
			$Sprite2D.flip_h = facing < 0
	


	move_and_slide()
