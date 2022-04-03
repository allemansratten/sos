extends Node

export(PackedScene) var game_over_hud

func _ready():
	$MapCamera.make_current()
	# randomize seeds generators
	randomize()
	$PartnerDriver.start()

var game_over_happened = false

func game_over(reason, no_partners, location):
	if game_over_happened:
		return
	game_over_happened = true
	
	# pause game but camera should be whitelisted
	get_tree().paused = true
	
	if typeof(location) == TYPE_VECTOR2:
		$MapCamera.death_zoom_in(location)

	$HUD.queue_free()
	var hud = game_over_hud.instance()
	var label = hud.find_node("Label")
	label.text = label.text.replace("REASON", reason).replace("NO_PARTNERS", no_partners)
	add_child(hud)

func refresh_phase(partner_count):
	var to_unlock = []
	if partner_count == 2:
		get_node("FogOfWar/Phase1").queue_free()
		to_unlock = get_tree().get_nodes_in_group("unlock_1")
	elif partner_count == 10:
		get_node("FogOfWar/Phase2").queue_free()
		to_unlock = get_tree().get_nodes_in_group("unlock_2")
		
	for n in to_unlock:
		print(n)
		n.locked = false
