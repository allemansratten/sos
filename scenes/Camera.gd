extends Camera2D


var mouse_start_pos
var screen_start_position

var dragging = false

var TILE_SIZE = 64

export var valid_region: Rect2 = Rect2(
	Vector2(-TILE_SIZE / 2, -TILE_SIZE / 2),
	Vector2(TILE_SIZE * 5, TILE_SIZE * 3)
)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# https://godotengine.org/qa/24969/how-to-drag-camera-with-mouse
func _input(event):
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
