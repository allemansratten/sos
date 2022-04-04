extends Node2D

class_name Partner

signal low_patience
signal goal_satisfied

# https://raw.githubusercontent.com/godotengine/godot-docs/master/img/color_constants.png
const ALL_COLORS = ["orangered", "darkgreen", "dodgerblue", "orange"]

const MAX_JUMP_TIME_COEF = 0.8
const DEFAULT_JUMP_TIME = 0.5
const STEP_SIZE = 64
const FLAG_WIDTH = 48
const GOAL_RESCHEDULE = 10
const DEFAULTS = {
	"patience": 60,
	"speed": 1.5,
	"step_delay": 0.2,
	"goal_delay": 2,
	"num_colors": 1
}

onready var hud = get_node("/root/GameScene/HUD")
onready var root_script = get_node("/root/GameScene")
onready var patience_timer = get_node("PatienceTimer")
onready var goal_timer = get_node("GoalTimer")

var partner_name

# frame every second
var speed
var goal_delay
var step_delay
var patience
var num_colors
var direction = Vector2(0, 0)

var is_being_hit = false

var colors = []
var goal

var next_step = Vector2(0, 0)
var old_step = Vector2(0, 0)

const N_SPRITE_TYPES = 4
var sprite_type = 1  # 1 to N_SPRITE_TYPES

var partner_driver
var partner_type

var just_turned = false

func init(name: String, new_loc: Vector2, dir: Vector2, driver, config: Dictionary):
	partner_name = name
	partner_driver = driver

	position = new_loc
	old_step = position
	next_step = position
	direction = dir
	
	unpack_config(config)


func unpack_config(config: Dictionary):
	step_delay = config.get("step_delay", DEFAULTS["step_delay"])
	speed = config.get("speed", DEFAULTS["speed"])
	patience = config.get("patience", DEFAULTS["patience"])
	goal_delay = config.get("goal_delay", DEFAULTS["goal_delay"])
	num_colors = config.get("num_colors", DEFAULTS["num_colors"])


func random_color_choice(n_colors):
	# force duplicate
	var colors_tmp = ALL_COLORS + []
	# clear up previous colors
	colors = []
	for __ in range(n_colors):
		var color_i = randi() % colors_tmp.size()
		colors.append(colors_tmp.pop_at(color_i))


func random_goal_choice():
	goal = root_script.legit_goals[randi() % root_script.legit_goals.size()]
	$DesireThoughtSprite/Label.set_text(goal)
	$DesireThoughtSprite.show()
	$PatienceTimer.start()


# Called on collision with goal
func schedule_random_goal_choice():
	goal = null
	$PatienceTimer.stop()  # So you don't lose after satisfying
	emit_signal("goal_satisfied")
	$SatisfiedTween.interpolate_property(
		self, "scale", scale, Vector2.ZERO, 0.75,
		Tween.TRANS_CIRC, Tween.EASE_IN_OUT
	)
	$SatisfiedTween.start()
	$GoalTimer.start(goal_delay)
	$CollisionShape2D.set_deferred("disabled", true)
	$StepTimer.stop()


func die(reason):
	#modulate = Color("#904949")
	if reason != null:
		get_parent().game_over(reason, partner_driver.partner_count, position)


func make_flag(flag_colors):
	# WARNING: will not work with more flags
	for c_i in range(len(flag_colors)):
		$FlagSprite.modulate = ColorN(flag_colors[c_i], 1)
		#var flag = ColorRect.new()
		#flag.rect_size.x = 10
		#flag.rect_size.y = 14
		#flag.rect_position.x = -(STEP_SIZE/2) + 8.2
		#flag.rect_position.y = -19 + (c_i * flag.rect_size.y)
		#flag.color = ColorN(flag_colors[c_i], 1)
		#add_child(flag)


# Called when the node enters the scene tree for the first time.
func _ready():
	# trick to hide FOUC
	scale = Vector2.ZERO
	
	random_color_choice(num_colors)
	random_goal_choice()
	make_flag(colors)
	
	$StepTimer.start(speed + step_delay)
	$PatienceTimer.start(patience)

	sprite_type = randi() % N_SPRITE_TYPES + 1
	reset_animation()

	# spawn animation
	# rotation
	$SatisfiedTween.interpolate_property($AnimatedSprite, "rotation_degrees",
		0, 360, 0.75,
		Tween.TRANS_CIRC, Tween.EASE_IN_OUT
	)
	# scale
	$SatisfiedTween.interpolate_property(self, "scale",
		Vector2.ZERO, Vector2.ONE, 0.75,
		Tween.TRANS_CIRC, Tween.EASE_IN_OUT
	)
	$SatisfiedTween.start()


func _process(_delta):
	# update patience bar
	$PatienceIndicator.rect_size.x = int(76*$PatienceTimer.time_left/patience)
	if goal == null:
		$PatienceIndicatorBack.rect_size.x = 0
	else:
		$PatienceIndicatorBack.rect_size.x = int(80*$PatienceTimer.time_left/patience+4)
	$PatienceIndicator.modulate = Color(
		1,
		0.2 + 0.8*$PatienceTimer.time_left/patience,
		0.2 + 0.8*$PatienceTimer.time_left/patience,
		1
	)
	if not $PatienceTimer.is_stopped() and $PatienceTimer.time_left < 15:
		emit_signal("low_patience")


func reset_animation():
	$AnimatedSprite.animation = "sprite%s" % sprite_type
	$AnimatedSprite.playing = false
	$AnimatedSprite.frame = 0


func post_jump_callback():
	reset_animation()
	$WalkAudioStream.pitch_scale = 1


func _process_timestep():
	next_step += direction * STEP_SIZE
	
	var jump_time = min(DEFAULT_JUMP_TIME, speed * MAX_JUMP_TIME_COEF)
	
	$StepTween.interpolate_property(self, "position",
		old_step, next_step, jump_time,
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT)

	$AnimatedSprite.flip_h = direction[0] < 0
	$AnimatedSprite.frame = 1

	if just_turned:
		# Make a high-pitched noise on the jump after a turn
		$WalkAudioStream.pitch_scale = 1.5
		just_turned = false

	$StepTween.interpolate_callback(self, jump_time, "post_jump_callback")
	$StepTween.start()

	$WalkAudioStream.play()
	old_step = next_step


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
		die("%s met with %s and discovered you were dating both of them" % [partner_name, partner.partner_name])
		partner.die(null)

	# return dominance
	partner.is_being_hit = true


func area_entered(other):
	if other.is_in_group("partner"):
		collide_with_partner(other)
	elif other.is_in_group("crossroads"):
		var cur_direction = direction
		direction = other.get_output_direction(direction)
		if cur_direction != direction:
			just_turned = true
	elif other.is_in_group("places"):
		if other.place == goal:
			$PlaceEnteredAudioStream.play()
			schedule_random_goal_choice()


func mouse_entered():
#	$StepTimer.stop()
	hud.update_partner_tracker(self)


func highlight_on(visible_val):
	$HighlightRect.visible = visible_val

# New goal will be chosen now
func _on_GoalRescheduleTimer_timeout():
	random_goal_choice()

# Make next step
func _on_StepTimer_timeout():
	_process_timestep()

# Ran out of patience
func _on_PatienceTimer_timeout():
	die("%s didn't get to %s in time" % [partner_name, goal.to_upper()])	

# Appear back after entering goal
func _on_GoalTimer_timeout():
	$SatisfiedTween.interpolate_property(self, "scale",
		Vector2.ZERO, Vector2.ONE, 0.75,
		Tween.TRANS_CIRC, Tween.EASE_IN_OUT
	)
	$SatisfiedTween.start()
	$CollisionShape2D.set_disabled(false)
	$GoalRescheduleTimer.start(GOAL_RESCHEDULE)
	$StepTimer.start(speed + step_delay)
	goal = null
