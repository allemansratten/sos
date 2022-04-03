tool # spusti kod i v editoru
extends Area2D

export(PackedScene) var arrow_scene

export var directions_mask = {
	Vector2.DOWN: true,
	Vector2.UP: true,
	Vector2.RIGHT: true,
	Vector2.LEFT: true,
}

onready var parent = get_parent()

static func rotate_vector_clockwise(vec: Vector2, steps=1):
	return vec.rotated((PI/2) * steps ).round()


var arrow_sprites = {
	Vector2.DOWN: null,
	Vector2.UP: null,
	Vector2.RIGHT: null,
	Vector2.LEFT: null,
}


func dir_is_open(dir: Vector2):
	if directions_mask[dir] is int and directions_mask[dir] <= parent.get_phase():
		return true
	return directions_mask[dir] is bool and directions_mask[dir]


func make_arrow(dir: Vector2):
	var arrow = arrow_scene.instance()
	arrow.rotate(dir.angle() + PI/2)
	return arrow
	

func set_arrow(dir: Vector2, visible: bool):
	if visible and arrow_sprites[dir] == null:
		arrow_sprites[dir] = make_arrow(dir)
		add_child(arrow_sprites[dir])
	elif visible and arrow_sprites[dir] != null:
		arrow_sprites[dir].show()
	elif not visible and arrow_sprites[dir] != null:
		arrow_sprites[dir].hide()


func render_arrows():
	for dir in directions_mask:
		set_arrow(dir, dir_is_open(dir))


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
