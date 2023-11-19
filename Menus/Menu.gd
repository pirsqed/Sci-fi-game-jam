extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		_on_startbutton_pressed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_startbutton_pressed():
	get_tree().change_scene_to_file("res://Opening/opening.tscn");

func _on_quit_pressed():
	get_tree().quit()
