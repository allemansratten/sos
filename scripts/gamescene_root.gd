extends Node

export(PackedScene) var game_over_hud

const GOALS_0 = ["diner", "cafe", "library", "museum"]
const GOALS_1 = ["gallery", "disco"]
const GOALS_2 = ["villa", "restaurant", "forest"]
const GOALS_3 = ["mall", "gym", "pool"]
var legit_goals = GOALS_0

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

	$MusicPlayer.stop()
	$GameOverPlayer.play()
	
	if typeof(location) == TYPE_VECTOR2:
		$MapCamera.death_zoom_in(location)

	$HUD.queue_free()
	var hud = game_over_hud.instance()
	var label = hud.find_node("Label")
	label.text = label.text.replace("REASON", reason).replace("NO_PARTNERS", no_partners)
	add_child(hud)

func get_phase(partner_count):
	
	if partner_count >= 5:
		return 3
	elif partner_count >= 4:
		return 2
	elif partner_count >= 2:
		return 1
	return 0

var processed_phase = 0

func refresh_phase(partner_count):
	var to_unlock = []
	if get_phase(partner_count) == 1 and processed_phase == 0: 
		get_node("FogOfWar/Phase1").queue_free()
		to_unlock = get_tree().get_nodes_in_group("unlock_1")
		legit_goals += GOALS_1
		processed_phase += 1
	elif get_phase(partner_count) == 2 and processed_phase == 1:
		get_node("FogOfWar/Phase2").queue_free()
		to_unlock = get_tree().get_nodes_in_group("unlock_2")
		legit_goals += GOALS_2
		processed_phase += 1
	elif get_phase(partner_count) == 3 and processed_phase == 2:
		get_node("FogOfWar/Phase3").queue_free()
		to_unlock = get_tree().get_nodes_in_group("unlock_3")
		legit_goals += GOALS_3
		processed_phase += 1
		
	for n in to_unlock:
		n.locked = false
