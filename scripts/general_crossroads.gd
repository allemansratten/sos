tool # spusti kod i v editoru
extends Area2D

export(PackedScene) var arrow_scene
const MAX_INT = 9223372036854775807 # this is not builtin

export var directions_mask = {
	Vector2.DOWN: MAX_INT,
	Vector2.UP: MAX_INT,
	Vector2.RIGHT: MAX_INT,
	Vector2.LEFT: MAX_INT,
}

onready var parent = get_parent()

static func rotate_vector_clockwise(vec: Vector2, steps=1):
	return vec.rotated((PI/2) * steps ).round()


func dir_is_open(dir: Vector2):
	if directions_mask[dir] is int and directions_mask[dir] <= parent.get_phase():
		return true
	return directions_mask[dir] is bool and directions_mask[dir]


func render_arrows():
	for dir in directions_mask:
		if dir_is_open(dir):
			var arrow = arrow_scene.instance()
			arrow.rotate(dir.angle() + PI/2)
			add_child(arrow)


func check_mask():
	var any_set = false
	for dir in directions_mask:
		if dir:
			any_set = true
	
	assert(any_set, "Invalid directions_mask")


# Called when the node enters the scene tree for the first time.
func _ready():
	check_mask()


func get_output_direction(_in_direction: Vector2):
	assert(false, "Must be implemented in child")
