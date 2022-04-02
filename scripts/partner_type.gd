class_name PartnerType


static func random_partner_type():
	randomize()  # for some reason necessary even if it's in GameScene as well

	var types = [VanillaPartnerType, UnreliablePartnerType]
	var instance = types[randi() % 2].new()

	return instance


class VanillaPartnerType:
	
	var partner
	var name
	
	func init(p):
		partner = p
		name = "vanilla"
	
	func collide_with_crossroads(crossroads):
		partner.direction = crossroads.get_output_direction(partner.direction)
		pass


class UnreliablePartnerType extends VanillaPartnerType:

	func init(p):
		.init(p)
		name = "unreliable"
	
	func collide_with_crossroads(crossroads):
		# Pretends they're coming from a random direction
		var dirs = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
		var dir = dirs[randi() % 4]

		partner.direction = crossroads.get_output_direction(dir)
