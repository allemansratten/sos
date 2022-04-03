extends Node

export(PackedScene) var partner_scene
onready var spawnable_locations = get_node("/root/GameScene/SpawnableLocations")
onready var hud = get_node("/root/GameScene/HUD")
onready var crossroads = get_node("/root/GameScene/AllCrossroads")

export var SPAWN_DELAY = 30
var spawn_time = SPAWN_DELAY

# this is stringly-typed and should be replaced but zouharvi doesnt know better
onready var baby_generator = load("res://scripts/baby_names.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: this randomize call should be used only once and somewhere up but whatever
	randomize()
	spawn_partner()
	# we need this hack because otherwise they may spawn on the same loc
	# (because of some ECS thing) -zouharvi
	yield(get_tree().create_timer(1.0), "timeout")
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
	
	partner.init(
		baby_generator.get_random_baby_mut(partner_i),
		new_loc,
		Vector2((randi()%2)*2-1, 0),
		self,
		0.1
	)
	add_child(partner)
	crossroads.inc_phase()
	hud.update_total_partner(partner_i)
	hud.send_pickup_line(partner.partner_name)
	
func game_over(reason, no_partners, location):
	# this relays the game_over call from partner
	get_parent().game_over(reason, no_partners, location)

func _process(delta):
	spawn_time -= delta
	if spawn_time <= 0:
		spawn_time = SPAWN_DELAY
		spawn_partner()

	hud.update_next_partner(spawn_time)
