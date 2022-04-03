extends Node


func _ready():
	$MapCamera.make_current()
	# randomize seeds generators
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var game_over_happened = false

func game_over(reason, location):
	if game_over_happened:
		return
	game_over_happened = true
	
	print("GAME OVER BECAUSE OF: [", reason, "]")
	# pause game but camera should be whitelisted
	get_tree().paused = true
	
	if typeof(location) == TYPE_VECTOR2:
		$MapCamera.death_zoom_in(location)
	
