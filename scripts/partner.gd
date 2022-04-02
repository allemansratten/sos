extends Node2D

const ALL_COLORS = ["red", "green", "blue", "pink", "yellow"]
const ALL_GOALS = ["cafe", "cinema", "park", "library", "gallery", "disco"]

# frame every 3/4 a second
const SPEED_TIMESTEP = 0.75
const STEP_SIZE = 64
onready var tween = get_node("StepTween")

var speed = STEP_SIZE
var dir_x = 0
var dir_y = 0

var is_being_hit = false

var colors = []
var goal
var patience = 2.0
var step_delay = 0

var delta_acc = 0
var next_step_x = 0
var next_step_y = 0
var old_step_x = 0
var old_step_y = 0


func init(x, y, d_x=0, d_y=0, delay=0):
	print_debug("Spawning partner at [%d, %d], dir [%d, %d], speed: %d" % [x, y, d_x, d_y, speed])
	position.x = x
	old_step_x = x
	next_step_x = x

	position.y = y
	old_step_y = y
	next_step_y = y

	dir_x = d_x
	dir_y = d_y	
	step_delay = delay

	# Hack to rotate the sprite
	set_direction(get_direction())


func random_color_choice(n_colors=2):
	# force duplicate
	var colors_tmp = ALL_COLORS + []
	# clear up previous colors
	colors = []
	for __ in range(n_colors):
		var color_i = randi() % colors_tmp.size()
		colors.append(colors_tmp.pop_at(color_i))


func random_goal_choice():
	goal = ALL_GOALS[randi() % ALL_GOALS.size()]


func die():
	modulate = Color("#904949")


func make_flag(flag_colors):
	for c_i in range(len(flag_colors)):
		var flag = ColorRect.new()
		flag.rect_position.x = -STEP_SIZE/2 + c_i*10
		flag.rect_position.y = -STEP_SIZE/2
		flag.color = ColorN(flag_colors[c_i], 1)
		flag.rect_size.x = 10
		flag.rect_size.y = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	random_color_choice(2)
	random_goal_choice()
	add_child(make_flag(colors))


func _process(delta):
	delta_acc += delta
	if delta_acc >= SPEED_TIMESTEP + step_delay:
		delta_acc -= SPEED_TIMESTEP + step_delay
		_process_timestep()

	# process patience
	patience -= delta
	if patience <= 0:
		# TODO: this will break when the parent is not the node with game_over function
		get_parent().game_over("patience")
	else:
		pass


func _process_timestep():
	next_step_x = next_step_x + dir_x * speed
	next_step_y = next_step_y + dir_y * speed
	tween.interpolate_property(self, "position",
		Vector2(old_step_x, old_step_y), Vector2(next_step_x, next_step_y), SPEED_TIMESTEP,
		Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween.start()
	old_step_x = next_step_x
	old_step_y = next_step_y


func check_color_intersect(other_colors):
	for c in colors:
		if c in other_colors:
			return true
	return false


func area_entered(other):
	if other.is_in_group("partners"):
		# Colliding with another partner
		if is_being_hit:
			return
		# establish dominance
		other.is_being_hit = true

		if check_color_intersect(other.colors):
#			print("COLOR HIT oh no")
			die()
			other.die()
			get_parent().game_over("color hit")

		# return dominance
		other.is_being_hit = true
	elif other.is_in_group("crossroads"):
		collide_with_crossroads(other)
	elif other.is_in_group("places"):
		other.collide(self)

func get_direction():
	if dir_y == -1:
		return 0
	if dir_x == 1:
		return 1
	if dir_y == 1:
		return 2
	if dir_x == -1:
		return 3

	assert(false)


func set_direction(direction):
	dir_x = [0, 1, 0, -1][direction]
	dir_y = [-1, 0, 1, 0][direction]
	rotation = (direction - 1) * 0.5 * PI


func collide_with_crossroads(crossroads):
	var in_direction = get_direction()
	var out_direction = crossroads.get_output_direction(in_direction)
	set_direction(out_direction)
