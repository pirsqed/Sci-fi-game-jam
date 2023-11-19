extends Node2D

@onready var player = load("res://player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()


func spawn_player(pos):
	player = load("res://player.tscn")
	var instance = player.instantiate()
	instance.position = pos
	add_child.call_deferred(instance)
