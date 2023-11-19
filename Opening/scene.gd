extends Sprite2D

var scene1_1 = load("res://Opening/Scene1_1.png") 
var scene1_2 = load("res://Opening/Scene1_2.png") 
var scene1_3 = load("res://Opening/Scene1_3.png") 
var scene2_1 = load("res://Opening/Scene2_1.png") 
var scene3_1 = load("res://Opening/Scene3_1.png") 

func _ready():
	texture = scene1_1


func _on_scenetimer_1_timeout():
	texture = scene1_2


func _on_scenetimer_2_timeout():
	texture = scene1_3


func _on_scenetimer_3_timeout():
	texture = scene2_1


func _on_scenetimer_4_timeout():
	texture = scene3_1
	
	
	
