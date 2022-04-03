extends Node

export(PackedScene) var partner_scene
onready var spawnable_locations = get_node("/root/GameScene/SpawnableLocations")
onready var next_partner_label = get_node("/root/GameScene/HUD/NextPartnerLabel")
onready var total_partner_label = get_node("/root/GameScene/HUD/PartnerCount")

const SPAWN_DELAY = 6
var spawn_time = SPAWN_DELAY

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: this randomize call should be used only once and somewhere up but whatever
	randomize()
	spawn_partner()
	spawn_partner()

var partner_i = 0

func spawn_partner():
	
	var locs_all = spawnable_locations.get_children()
	var locs_free = Array()
	for loc in locs_all:
		if loc.is_free():
			locs_free.append(loc)
	
	if locs_free.size() == 0:
		# no free places to spawn, skip
		# TODO: better handling
		return
	
	var partner = partner_scene.instance()
	partner_i += 1
	# TODO: here we randomly select left/right but a better solution would be if
	# the SpawnableLocation had a direction mask
	var new_loc = locs_free[randi() % locs_free.size()].position
	
	partner.init(new_loc, Vector2((randi()%2)*2-1, 0), 0.1)
	add_child(partner)
	total_partner_label.text = str(partner_i) + " partners"

func game_over(reason, location):
	# this relays the game_over call from partner
	get_parent().game_over(reason, location)

func _process(delta):
	spawn_time -= delta
	if spawn_time <= 0:
		spawn_time = SPAWN_DELAY
		spawn_partner()

	next_partner_label.text = "Next partner in %ds" % [spawn_time]
