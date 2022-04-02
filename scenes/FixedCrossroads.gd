extends Area2D

export(PackedScene) var arrow_scene

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var directions_mask = [true, true, true, true]

# Called when the node enters the scene tree for the first time.
func _ready():
	# Only used for the preview.
	$PreviewSprite.hide()
	
	var any_set = false
	
	for i in range(4):
		if directions_mask[i]:
			any_set = true
			var arrow = arrow_scene.instance()
			arrow.rotate(i * 0.5 * PI)
#			arrow.move_local_x(32)
#			arrow.move_local_y(32)
			#arrow.translate(Vector2(32, 32))
			add_child(arrow)
	
	assert(any_set) # No directions set in directions_mask

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
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
