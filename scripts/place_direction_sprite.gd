extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var places = null


func find_places_by_name(name):
	places = []
	var all_places = get_tree().get_nodes_in_group("places")
	for place in all_places:
		if place.place == name:
			places.append(place)

	assert(len(places) > 0, "No place named " + name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_time_delta):
	var partner = get_parent()
	var goal = partner.goal

	if goal != null:
		show()
		if places == null:
			find_places_by_name(goal)

		var best_distance = 1e9
		var best_place = null
		for place in places:
			var distance = (place.global_position - partner.global_position).length()
			if distance < best_distance:
				best_distance = distance
				best_place = place

		var pos_delta = best_place.global_position - partner.global_position
		rotation = pos_delta.angle() # + PI * 0.5
	
	else:
		hide()
		places = null
