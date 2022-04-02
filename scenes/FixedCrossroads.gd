tool # spusti kod i v editoru

extends "res://scripts/general_crossroads.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	render_arrows()
	# Only used for the preview.
	$PreviewSprite.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pozor: pousti se i v editoru kvuli `tool`
#	pass

func get_output_direction(in_direction):
	var straight = (in_direction + 0) % 4
	var right = (in_direction + 1) % 4
	var back = (in_direction + 2) % 4
	var left = (in_direction + 3) % 4

	if directions_mask[straight]:
		# go straight through
		return straight
	elif directions_mask[right]:
		return right
	elif directions_mask[left]:
		return left
	else:
		# Otherwise no direction is available
		assert(directions_mask[back])
		return back
