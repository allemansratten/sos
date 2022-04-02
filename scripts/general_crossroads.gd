tool # spusti kod i v editoru
extends Area2D

export(PackedScene) var arrow_scene

export var directions_mask = {
	Vector2.DOWN: true,
	Vector2.UP: true,
	Vector2.RIGHT: true,
	Vector2.LEFT: true,
}


func rotate_vector_clockwise(vec: Vector2, steps=1):
	return vec.rotated((PI/2) * steps ).round()


func render_arrows():
	for dir in directions_mask:
		if directions_mask[dir]:
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
