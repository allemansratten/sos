tool # spusti kod i v editoru

extends "res://scripts/general_crossroads.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	render_arrows()
	# Only used for the preview.
	$PreviewSprite.hide()


func get_output_direction(in_direction: Vector2):
	if directions_mask[in_direction]:  # go straight through		
		return in_direction
	# Go right
	elif directions_mask[rotate_vector_clockwise(in_direction, 1)]:
		return rotate_vector_clockwise(in_direction, 1)
	# Go left
	elif directions_mask[rotate_vector_clockwise(in_direction, 3)]:
		return rotate_vector_clockwise(in_direction, 3)
	# Go back
	else:
		# Otherwise no direction is available
		assert(directions_mask[rotate_vector_clockwise(in_direction, 2)])
		return rotate_vector_clockwise(in_direction, 2)
