class VanillaCrossroadStrategy:
	func get_name():
		return "vanilla"

	func collide(crossroads, in_direction):
		return crossroads.get_output_direction(in_direction)


class UnreliableCrossroadStrategy:
	func get_name():
		return "unreliable"

	func collide(crossroads, in_direction):
		# Sometimes pretends they're coming from a random direction
		var dir
		if randi() % 10 == 0:
			dir = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT][randi() % 4]
		else:
			dir = in_direction
		return crossroads.get_output_direction(dir)
