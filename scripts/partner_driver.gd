extends Node

onready var spawnable_locations = get_node("/root/GameScene/SpawnableLocations")
onready var hud = get_node("/root/GameScene/HUD")
onready var root_script = get_node("/root/GameScene")
onready var partner_factory = PartnerFactory.new()

var partner_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func start():
	# TODO: this randomize call should be used only once and somewhere up but whatever
	randomize()
	spawn_partner()
	# we need this hack because otherwise they may spawn on the same loc
	# (because of some ECS thing) -zouharvi
	yield(get_tree().create_timer(10.0), "timeout")
	#spawn_partner()


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

	partner_count += 1
	# TODO: here we randomly select left/right but a better solution would be if
	# the SpawnableLocation had a direction mask
	var new_loc = locs_free[randi() % locs_free.size()].position
	var partner = $PartnerFactory.make_partner(new_loc)
	add_child(partner)

	root_script.refresh_phase(partner_count)
	
	if root_script.get_phase(partner_count) == 1:
		$SpawnTimer.wait_time = 50
		$SpawnTimer.start()
	elif root_script.get_phase(partner_count) == 2:
		$SpawnTimer.wait_time = 60
		$SpawnTimer.start()
	elif root_script.get_phase(partner_count) == 3:
		$SpawnTimer.wait_time = 70
		$SpawnTimer.start()
	
func game_over(reason, no_partners, location):
	# this relays the game_over call from partner
	get_parent().game_over(reason, no_partners, location)


func _on_SpawnTimer_timeout():
	spawn_partner()
