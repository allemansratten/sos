extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Partner_mouse_entered():
	show()


func _on_Partner_mouse_exited():
	hide()
