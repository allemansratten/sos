class_name PartnerFactory

extends Node
export(PackedScene) var partner_scene

onready var hud = get_node("/root/GameScene/HUD")
onready var partner_driver = get_node("/root/GameScene/PartnerDriver")

func make_partner(location, partner_driver):
	var partner_instance = partner_scene.instance()
	var partner_config = $PartnerCatalgoue.get_random_partner_config()
#	var partner_config = $PartnerCatalgoue.get_partner_config("impatient")
	
	partner_instance.init(
		$BabyGenerator.get_random_baby_mut(),
		location,
		Vector2.DOWN,
		partner_driver,
		partner_config
	)
	hud.update_total_partner(partner_driver.partner_count)
	hud.send_pickup_line(partner_instance.partner_name)
	return partner_instance
