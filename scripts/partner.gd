extends Node2D

class_name Partner

# https://raw.githubusercontent.com/godotengine/godot-docs/master/img/color_constants.png
const ALL_COLORS = ["orangered", "limegreen", "dodgerblue", "whitesmoke", "orange"]
const ALL_GOALS = ["cafe", "cinema", "park", "library", "gallery", "disco"]

# frame every  second
const SPEED_TIMESTEP = 1
const STEP_SIZE = 64
const FLAG_WIDTH = 48
const GOAL_RESCHEDULE = 10
const PATIENCE_RESCHEDULE = 60
onready var step_tween = get_node("StepTween")
onready var satisfied_tween = get_node("SatisfiedTween")
onready var hud = get_node("/root/GameScene/HUD")
onready var patience_indicator = get_node("PatienceIndicator")

var partner_name

var speed = SPEED_TIMESTEP
var direction = Vector2(0, 0)

var is_being_hit = false

var colors = []
var goal
var patience = PATIENCE_RESCHEDULE
var step_delay = 0

var delta_acc = 0
var delta_goal_acc = 0
# TODO: this should be a Vector2
var next_step_x = 0
var next_step_y = 0
var old_step_x = 0
var old_step_y = 0

var partner_type

func init(name: String, new_loc: Vector2, dir: Vector2, delay=0):
	partner_type = PartnerType.new()
	partner_type.init(self, "random")
	
	partner_name = name

	#print_debug("Spawning partner at [%d, %d], dir [%d, %d], speed: %f, crossroad_type: %s" % [x, y, dir[0], dir[1], speed, partner_type.crossroad_strategy.get_name()])

	position = new_loc
	old_step_x = new_loc.x
	next_step_x = new_loc.x
	old_step_y = new_loc.y
	next_step_y = new_loc.y

	direction = dir
	step_delay = delay


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
	patience = PATIENCE_RESCHEDULE
	

func schedule_random_goal_choice():
	satisfied_tween.interpolate_property(self, "rotation_degrees",
		0, 360, 0.75,
		Tween.TRANS_CIRC, Tween.EASE_IN_OUT
	)
	satisfied_tween.start()
	
	delta_goal_acc = GOAL_RESCHEDULE
	goal = null
	patience = PATIENCE_RESCHEDULE

func die(reason):
	modulate = Color("#904949")
	get_parent().game_over(reason, position-Vector2(64*3, 0))

func make_flag(flag_colors):
	
	for c_i in range(len(flag_colors)):
		var flag = ColorRect.new()
		flag.rect_position.x = -FLAG_WIDTH/2 + c_i*FLAG_WIDTH/len(flag_colors)
		flag.rect_position.y = -STEP_SIZE/2+5
		flag.color = ColorN(flag_colors[c_i], 1)
		flag.rect_size.x = FLAG_WIDTH/len(flag_colors)
		flag.rect_size.y = 5
		add_child(flag)

# Called when the node enters the scene tree for the first time.
func _ready():
	# trick to hide FOUC
	scale = Vector2.ZERO
	
	random_color_choice(randi()%5)
	random_goal_choice()
	make_flag(colors)
	
	# spawn animation
	# rotation
	satisfied_tween.interpolate_property(self, "rotation_degrees",
		0, 360, 0.75,
		Tween.TRANS_CIRC, Tween.EASE_IN_OUT
	)
	# scale
	satisfied_tween.interpolate_property(self, "scale",
		Vector2.ZERO, Vector2.ONE, 0.75,
		Tween.TRANS_CIRC, Tween.EASE_IN_OUT
	)
	# alpha (doesn't really work)
	#satisfied_tween.interpolate_property(self, "modulate",
	#	Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.75,
	#	Tween.TRANS_CIRC, Tween.EASE_IN_OUT
	#)
	satisfied_tween.start()

func _process(delta):
	delta_acc += delta
	if delta_acc >= SPEED_TIMESTEP + step_delay:
		delta_acc -= SPEED_TIMESTEP + step_delay
		_process_timestep()

	# process patience
	patience -= delta
	if patience <= 0:
		die("patience")

	# process goal rescheduling
	delta_goal_acc -= delta
	if (goal == null) and (delta_goal_acc <= 0):
		random_goal_choice()
		
	patience_indicator.rect_scale.x = 1 - patience/PATIENCE_RESCHEDULE


func _process_timestep():
	next_step_x = next_step_x + direction[0] * STEP_SIZE
	next_step_y = next_step_y + direction[1] * STEP_SIZE
	step_tween.interpolate_property(self, "position",
		Vector2(old_step_x, old_step_y), Vector2(next_step_x, next_step_y), SPEED_TIMESTEP,
		Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	step_tween.start()
	old_step_x = next_step_x
	old_step_y = next_step_y


func check_color_intersect(other_colors):
	for c in colors:
		if c in other_colors:
			return true
	return false


func collide_with_partner(partner):
	# Colliding with another partner
	if is_being_hit:
		return
	# establish dominance
	partner.is_being_hit = true

	if check_color_intersect(partner.colors):
		die("encounter")
		partner.die("encounter")

	# return dominance
	partner.is_being_hit = true


func area_entered(other):
	if other.is_in_group("partner"):
		collide_with_partner(other)
	elif other.is_in_group("crossroads"):
		partner_type.collide_with_crossroads(other)
	elif other.is_in_group("places"):
		other.collide(self)


func mouse_entered():
	hud.update_partner_tracker(self)

func highlight_on(visible_val):
	$HighlightRect.visible = visible_val
