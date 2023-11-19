extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().get_child(0).spawn_player(position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
