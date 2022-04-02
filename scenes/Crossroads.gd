extends Area2D


# 0 az 3, v poradi [12, 3, 6, 9]
var direction = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_direction(to: int):
	assert(0 <= to && to <= 3)
	direction = to
	rotation = direction * 2 * PI / 4.0

func on_click():
	set_direction((direction + 1) % 4)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.pressed:
		self.on_click()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
