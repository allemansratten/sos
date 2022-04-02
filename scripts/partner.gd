extends Node2D

const ALL_COLORS = ["red", "green", "blue", "pink", "yellow"]
const ALL_GOALS = ["cafe", "cinema", "park", "library", "gallery", "disco"]

# frame every  second
const SPEED_TIMESTEP = 1
const STEP_SIZE = 64
const GOAL_RESCHEDULE = 10
const PATIENCE_RESCHEDULE = 60
onready var tween = get_node("StepTween")
onready var goal_label = get_node("GoalLabel")

var speed = SPEED_TIMESTEP
var direction = Vector2(0, 0)

var is_being_hit = false

var colors = []
var goal
var patience = PATIENCE_RESCHEDULE
var step_delay = 0

var delta_acc = 0
var delta_goal_acc = 0
var next_step_x = 0
var next_step_y = 0
var old_step_x = 0
var old_step_y = 0


func init(x, y, d_x=0, d_y=0, delay=0):
	print_debug("Spawning partner at [%d, %d], dir [%d, %d], speed: %f" % [x, y, d_x, d_y, speed])
	position.x = x
	old_step_x = x
	next_step_x = x

	position.y = y
	old_step_y = y
	next_step_y = y
	
	direction = Vector2(d_x, d_y)
	step_delay = delay

	# Hack to rotate the sprite
#	set_direction(get_direction())


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
	goal_label.text = goal
	patience = PATIENCE_RESCHEDULE

func schedule_random_goal_choice():
	delta_goal_acc = GOAL_RESCHEDULE
	goal = "..."
	patience = PATIENCE_RESCHEDULE

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
		add_child(flag)


# Called when the node enters the scene tree for the first time.
func _ready():
	random_color_choice(2)
	random_goal_choice()
	make_flag(colors)


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
		
	# process goal rescheduling
	if goal == "...":
		goal_label.text = goal
	else:
		goal_label.text = goal + " (" + str(int(patience)) + "s)"
	delta_goal_acc -= delta
	if (goal == "...") and (delta_goal_acc <= 0):
		random_goal_choice()


func _process_timestep():
	next_step_x = next_step_x + direction[0] * STEP_SIZE
	next_step_y = next_step_y + direction[1] * STEP_SIZE
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

#func get_direction():
#	if direction == Vector2.UP:
#		return 0
#	if direction == Vector2.RIGHT:
#		return 1
#	if direction == Vector2.DOWN:
#		return 2
#	if direction == Vector2.LEFT:
#		return 3
#
#	assert(false)
#
#
#func set_direction(dir):
#	direction[0] = [0, 1, 0, -1][dir]
#	direction[1] = [-1, 0, 1, 0][dir]
#	rotation = (dir - 1) * 0.5 * PI


func collide_with_crossroads(crossroads):
#	var in_direction = get_direction()
#	var out_direction = crossroads.get_output_direction(in_direction)
#	set_direction(out_direction)
	direction = crossroads.get_output_direction(direction)
