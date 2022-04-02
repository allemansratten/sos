extends Node

export(PackedScene) var partner_scene


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_partner()
	spawn_partner()

var partner_i = 0

func spawn_partner():
	print("spawning")
	var partner = partner_scene.instance()
	partner_i += 1
	if partner_i == 1:
		partner.dir_x = 1
		partner.position.x = 64*1
		partner.position.y = 64*4
	elif partner_i == 2:
		partner.dir_y = -1
		partner.position.x = 64*5
		partner.position.y = 64*8
		
	add_child(partner)
	
func game_over(reason):
	# this relays the game_over call from partner
	get_parent().game_over(reason)
	
