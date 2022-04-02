class_name PartnerType

const CrossroadStrategies = preload("res://scripts/crossroad_strategies.gd")
const cross_strategies = {
	"vanilla": CrossroadStrategies.VanillaCrossroadStrategy,
	"unreliable": CrossroadStrategies.UnreliableCrossroadStrategy
}

var partner
var crossroad_strategy

static func get_random(dict):
	var keys = dict.keys()
	return dict[keys[randi() % keys.size()]]


func init(p, crossroad_strat: String="vanilla"):
	partner = p
	if crossroad_strat == "random":
		crossroad_strategy = get_random(cross_strategies).new()
	else:
		assert(crossroad_strat in cross_strategies, "Unknown crossroad strategy %s" % [crossroad_strat])
		crossroad_strategy = cross_strategies[crossroad_strat].new()


func collide_with_crossroads(crossroads):
	partner.direction = crossroad_strategy.collide(crossroads, partner.direction)
