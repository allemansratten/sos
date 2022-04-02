extends "res://scripts/general_crossroads.gd"

var direction = Vector2(0, -1)


# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	

func set_direction(to: Vector2):
	assert(directions_mask[to], "Invalid direction %s, mask is %s" % [to, directions_mask])
	direction = to
	$Sprite.rotation = direction.angle() + PI/2


func on_click():
	var d = direction
	for __ in directions_mask:
		d = rotate_vector_clockwise(d, 1).round()
		print_debug(d.round())
		if directions_mask[d.round()]:
			set_direction(d.round())
			return
	assert(false, "No crossroad mask open")


func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.pressed:
		self.on_click()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func get_output_direction(_in_direction: Vector2):
	# in_direction is used in FixedCrossroads
	return direction
