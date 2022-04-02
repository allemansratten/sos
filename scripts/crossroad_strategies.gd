class VanillaCrossroadStrategy:
	func get_name():
		return "vanilla"

	func collide(crossroads, in_direction):
		return crossroads.get_output_direction(in_direction)


class UnreliableCrossroadStrategy:
	func get_name():
		return "unreliable"

	func collide(crossroads, _in_direction):
		# Pretends they're coming from a random direction
		var dirs = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
		return crossroads.get_output_direction(dirs[randi() % 4])
