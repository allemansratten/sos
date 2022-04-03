extends Node2D

export var padding = 30

# The partner to follow.
var partner: Partner

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(time_delta):
	var camera: MapCamera = get_parent().get_parent().get_node("MapCamera")
	var screen_center = camera.get_camera_screen_center()
	var screen_size = get_viewport().get_visible_rect().size

	var delta = partner.position - screen_center

	if should_be_shown(delta, screen_size * camera.zoom):
		show()
		var marker_pos = get_marker_position(delta, screen_size)
		set_position(marker_pos)
	else:
		hide()


func should_be_shown(delta, screen_size):
	return not (delta.x < screen_size.x / 2 and 
		delta.x > -screen_size.x / 2 and
		delta.y < screen_size.y / 2 and
		delta.y > -screen_size.y / 2)


# https://gamedevelopment.tutsplus.com/tutorials/positioning-on-screen-indicators-to-point-to-off-screen-targets--gamedev-6644
func get_marker_position(delta, screen_size):
	var screen_size_padded = screen_size - Vector2(padding, padding)

	var slope
	if delta.x == 0:
		slope = 1e9
	elif delta.y == 0:
		slope = 1e-9
	else:
		slope = delta.y / delta.x;

	rotation = delta.angle()

	var pos = Vector2(0,0)

	if delta.y < 0:
		# Top of the screen
		pos = Vector2(-screen_size_padded.y/2/slope, -screen_size_padded.y/2)
	else:
		# Bottom
		pos = Vector2(screen_size_padded.y/2/slope, screen_size_padded.y/2)
#
	if pos.x < -screen_size_padded.x / 2:
		# The current position is still out of the screen - put it on the left side
		pos = Vector2(-screen_size_padded.x/2, slope * -screen_size_padded.x / 2)
	elif pos.x > screen_size_padded.x / 2:
		# The current position is still out of the screen - put it on the right side
		pos = Vector2(screen_size_padded.x/2, slope * screen_size_padded.x / 2)

	pos += screen_size / 2

	return pos
	
