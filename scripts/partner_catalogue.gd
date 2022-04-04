extends Node


# WARNING: don't use any other num_colors than 1 - they won't be displayed -zouharvi
const catalogue = {
	"normal": {
		"speed": Vector2(0.8, 1.2),
		"step_delay": Vector2(0.8, 1.2)
		
		
	}
}


static func make_instance(template):
	var instance = {}
	for item in template:
		if template[item] is Vector2:
			instance[item] = interval_random(template[item])
		elif template[item] is Array:
			instance[item] = template[item][randi() % len(template[item])]
		else:
			instance[item] = template[item]
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
