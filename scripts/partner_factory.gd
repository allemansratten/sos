class_name PartnerFactory

extends Node
export(PackedScene) var partner_scene

onready var crossroads = get_node("/root/GameScene/AllCrossroads")
onready var hud = get_node("/root/GameScene/HUD")

var partners_spawned = 0

func _ready():
	pass


func make_partner(location, partner_driver):
	var partner_instance = partner_scene.instance()
	var partner_config = $PartnerCatalogue.get_random_partner_config()
	
	partner_instance.init(
		$BabyGenerator.get_random_baby_mut(),
		location,
		Vector2((randi()%2)*2-1, 0),
		partner_driver,
		partner_config
	)
	crossroads.inc_phase()
	partners_spawned += 1
	hud.update_total_partner(partners_spawned)
	hud.send_pickup_line(partner_instance.partner_name)
	return partner_instance
