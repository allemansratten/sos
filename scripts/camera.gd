extends Camera2D

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
	var new_position = global_position + (-0.5*v0 + point)*(zoom - new_zoom)  # next camera position
	
	zoom_tween.interpolate_property(self, "zoom",
		zoom, new_zoom, zoom_time,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	zoom_tween.start()

	pos_tween.interpolate_property(self, "global_position",
		global_position, new_position, zoom_time,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	pos_tween.start()


func death_zoom_in(new_pos):
	zoom_at_point(0.5, new_pos, DIE_ZOOM_TIME)
