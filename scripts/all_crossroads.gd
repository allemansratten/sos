extends Node

var game_phase = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_phase():
	return game_phase


func inc_phase():
	game_phase += 1
	get_tree().call_group("crossroads", "render_arrows")
