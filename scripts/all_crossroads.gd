extends Node

var game_phase = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func get_phase():
	return game_phase


func _on_PhaseTimer_timeout():
	game_phase += 1
	get_tree().call_group("crossroads", "render_arrows")
