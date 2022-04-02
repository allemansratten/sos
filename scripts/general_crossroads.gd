tool # spusti kod i v editoru
extends Area2D

export(PackedScene) var arrow_scene

export var directions_mask = [true, true, true, true]

func render_arrows():
	for i in range(4):
		if directions_mask[i]:
			var arrow = arrow_scene.instance()
			arrow.rotate(i * 0.5 * PI)
#			arrow.move_local_x(32)
#			arrow.move_local_y(32)
			#arrow.translate(Vector2(32, 32))
			add_child(arrow)

func check_mask():
	var any_set = false
	for i in range(4):
		if directions_mask[i]:
			any_set = true
	
	assert(any_set, "Invalid directions_mask")

# Called when the node enters the scene tree for the first time.
func _ready():
	check_mask()

func get_output_direction(in_direction):
	assert(false, "Must be implemented in child")
