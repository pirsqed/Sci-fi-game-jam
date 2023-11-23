extends Area2D

@export var next_level:Resource
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("player"):
		var level = next_level.instantiate()
		get_tree().get_root().get_child(0).add_child(level)
		get_owner().queue_free()
	print(body)
