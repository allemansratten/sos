extends Camera2D

class_name MapCamera

onready var zoom_tween = get_node("ZoomTween")
onready var pos_tween = get_node("PosTween")

var mouse_start_pos
var screen_start_position

var dragging = false
var locked = false

const TILE_SIZE = 64
const DIE_ZOOM_TIME = 3
const ZOOM_STEP = 1.3
const MIN_ZOOM = Vector2.ONE * 0.5
const MAX_ZOOM = Vector2.ONE * 2


static func clamp_zoom(new_zoom):
	if new_zoom >= MAX_ZOOM:
		return MAX_ZOOM
	if new_zoom <= MIN_ZOOM:
		return MIN_ZOOM
	return new_zoom


# https://godotengine.org/qa/24969/how-to-drag-camera-with-mouse
func _input(event):
	if locked:
		return
		
	if event.is_action("drag"):
		if event.is_pressed():
			mouse_start_pos = event.position
			screen_start_position = position
			dragging = true
		else:
			dragging = false
			# this fixes a problem where the camera is dragged beyond the limits - you would
			# otherwise have to drag it back the same distance for it to start moving again
			position = get_camera_screen_center()

	elif event is InputEventMouseMotion and dragging:
		position = zoom * (mouse_start_pos - event.position) + screen_start_position
	elif event.is_action("camera_zoom_in"):
		zoom_at_point(1/ZOOM_STEP,event.position, 0.2)
	elif event.is_action("camera_zoom_out"):
		zoom_at_point(ZOOM_STEP,event.position, 0.2)


# https://godotengine.org/qa/25983/camera2d-zoom-position-towards-the-mouse
func zoom_at_point(zoom_change: float, point: Vector2, zoom_time: float):
	var c0 = global_position  # camera position
	var v0 = get_viewport().size  # vieport size
	var new_zoom = clamp_zoom(zoom * zoom_change)  # next zoom value

	# Compensate for the HUD by adding a vertical offset
	var new_position = point + Vector2(0, 64 * 0.5)
	
	zoom_tween.interpolate_property(self, "zoom",
		zoom, new_zoom, zoom_time,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	zoom_tween.start()

	pos_tween.interpolate_property(self, "global_position",
		get_camera_screen_center(), new_position, zoom_time,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	pos_tween.start()


func disable_camera_limits():
	set_limit(MARGIN_TOP, -1e6)
	set_limit(MARGIN_BOTTOM, 1e6)

	set_limit(MARGIN_LEFT, -1e6)
	set_limit(MARGIN_RIGHT, 1e6)


func death_zoom_in(new_pos):
	# Sometimes we need to move the camera beyond the normal limits
	disable_camera_limits()
	
	zoom_at_point(0.5, new_pos, DIE_ZOOM_TIME)
