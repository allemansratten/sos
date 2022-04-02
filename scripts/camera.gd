extends Camera2D

onready var zoom_tween = get_node("ZoomTween")
onready var pos_tween = get_node("PosTween")

var mouse_start_pos
var screen_start_position

var dragging = false
var locked = false

const TILE_SIZE = 64
const DIE_ZOOM_TIME = 3

export var valid_region: Rect2 = Rect2(
	Vector2(-TILE_SIZE / 2, -TILE_SIZE / 2),
	Vector2(TILE_SIZE * 5, TILE_SIZE * 3)
)

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
		position.x = clamp(position.x, valid_region.position.x, valid_region.position.x + valid_region.size.x)
		position.y = clamp(position.y, valid_region.position.y, valid_region.position.y + valid_region.size.y)
		
func zoom_in(new_pos):
	zoom_tween.interpolate_property(self, "zoom",
		zoom, 0.5*zoom, DIE_ZOOM_TIME,
		Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	zoom_tween.start()

	pos_tween.interpolate_property(self, "position",
		position, 0.5*new_pos, DIE_ZOOM_TIME,
		Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	pos_tween.start()
