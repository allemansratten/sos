extends Node

export(PackedScene) var partner_scene


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_partner()

func spawn_partner():
	print("spawning")
	var partner = partner_scene.instance()
	add_child(partner)
	
func game_over(reason):
	# this relays the game_over call from partner
	get_parent().game_over(reason)
	
