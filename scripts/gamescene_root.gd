extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	# randomize seeds generators
	$MapCamera.make_current()
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var game_over_happened = false

func game_over(reason):
	if game_over_happened:
		return
	game_over_happened = true
	print("GAME OVER BECAUSE OF: [", reason, "]")
