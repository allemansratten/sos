extends Node

const catalogue = {
	"normal": {
		"delay": Vector2(0.1, 0.5),
	},
	"slow": {
		"delay": Vector2(1, 2),
		"speed": Vector2(1.5, 3)
	},
}


static func make_instance(template):
	var instance = {}
	for item in template:
		instance[item] = interval_random(template[item])
	return instance


static func get_random_key(dict):
	var keys = dict.keys()
	return keys[randi() % keys.size()]


static func interval_random(interval: Vector2):
	return interval[0] + (interval[1] - interval[0]) * randf()


static func get_partner_config(type: String):
	if not type in catalogue:
		type = catalogue.keys()[0]
	return make_instance(catalogue[type])


static func get_random_partner_config():
	return get_partner_config(get_random_key(catalogue))
