extends Node

export(PackedScene) var partner_scene
#const Partner = preload("res://scenes/Partner.tscn")
onready var next_partner_label = get_node("/root/GameScene/NextPartnerLabel")

const SPAWN_DELAY = 6
var spawn_time = SPAWN_DELAY

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_partner()
	spawn_partner()

var partner_i = 0

func spawn_partner():
	var partner = partner_scene.instance()
	partner_i += 1
	if partner_i == 1:
		partner.init(64*5, 64*2, 1, 0, 0.1)
	elif partner_i == 2:
		partner.init(64*4, 64*6, 0, 1, 1)
	else:
		partner.init(64*0, 64*(1+randi()%10), 0, 1, 0.5)
	add_child(partner)


func game_over(reason):
	# this relays the game_over call from partner
	get_parent().game_over(reason)

func _process(delta):
	spawn_time -= delta
	if spawn_time <= 0:
		spawn_time = SPAWN_DELAY
		spawn_partner()

	next_partner_label.text = "Next partner in %ds" % [spawn_time]
