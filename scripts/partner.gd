extends Node2D

const ALL_COLORS = ["red", "green", "blue", "pink", "yellow"]
const ALL_GOALS = ["cafe", "cinema", "park", "library", "gallery", "disco"]

# frame every 3/4 a second
const SPEED_TIMESTEP = 0.75
const STEP_SIZE = 64

var speed = STEP_SIZE
var dir_x = 0
var dir_y = 0

var is_being_hit = false

var colors = []
var goal
var patience = 2.0

var delta_acc = 0
var next_step_x = 0
var next_step_y = 0
var old_step_x = 0
var old_step_y = 0


func init(x, y, d_x=0, d_y=0):
	print_debug("Spawning partner at [%d, %d], dir [%d, %d]" % [x, y, d_x, d_y])
	position.x = x
	old_step_x = x
	next_step_x = x
	
	position.y = y
	old_step_y = y
	next_step_y = y
	
	dir_x = d_x
	dir_y = d_y


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


func make_flag(colors):
	for c_i in range(len(colors)):
		var flag = ColorRect.new()
		flag.rect_position.x = -STEP_SIZE/2 + c_i*10
		flag.rect_position.y = -STEP_SIZE/2
		flag.color = ColorN(colors[c_i], 1)
		flag.rect_size.x = 10
		flag.rect_size.y = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	random_color_choice(2)
	random_goal_choice()
	add_child(make_flag(colors))


func _process(delta):
	delta_acc += delta
	if delta_acc >= SPEED_TIMESTEP:
		delta_acc -= SPEED_TIMESTEP
		_process_timestep()
	
	position.x = interpolate(old_step_x, next_step_x, delta_acc)
	position.y = interpolate(old_step_y, next_step_y, delta_acc)
	
	# process patience
	patience -= delta
	if patience <= 0:
		# TODO: this will break when the parent is not the node with game_over function
		get_parent().game_over("patience")
	else:
		pass


func interpolate(old_pos, new_pos, delta):
	var normalised_delta = delta / SPEED_TIMESTEP
	return old_pos + (old_pos - new_pos) * normalised_delta


func _process_timestep():
#	position.x += dir_x * speed
#	position.y += dir_y * speed
	old_step_x = position.x
	old_step_y = position.y
	next_step_x = position.x + dir_x * speed
	next_step_y = position.y + dir_y * speed


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
		set_direction(other.direction)


func set_direction(direction):
	#TODO: make this use Observer
	dir_x = [0, -1, 0, 1][direction]
	dir_y = [1, 0, -1, 0][direction]
