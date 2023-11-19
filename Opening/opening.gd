extends Node2D

#@onready var dialogue_label: DialogueLabel = $DialogueLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	#dialogue_label.hide()
	pass


func _on_scenetimer_4_timeout():
	# var words = load("res://opening.dialogue")
	#var dialogue_line = await DialogueManager.get_next_dialogue_line(words, "start")
	#dialogue_label.dialogue_line = dialogue_line
	#dialogue_label.show()
	#dialogue_label.type_out()
	pass


func _on_scenetimer_5_timeout():
	get_tree().change_scene_to_file("res://levels/level_1.tscn");
	
