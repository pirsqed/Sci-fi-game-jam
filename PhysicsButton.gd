extends RigidBody2D

signal is_button_active(state)

var state = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	var bodies = get_colliding_bodies()
	for body in bodies:
		if body.is_in_group("Button"):
			if not state:
				state = true
				print(state)
				is_button_active.emit(state)
			return
	
	if state:
		state = false
		print(state)
		is_button_active.emit(state)
