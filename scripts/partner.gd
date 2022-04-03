extends Node2D

class_name Partner

# https://raw.githubusercontent.com/godotengine/godot-docs/master/img/color_constants.png
const ALL_COLORS = ["orangered", "limegreen", "dodgerblue", "whitesmoke", "orange"]

const JUMP_TIME_COEF = 0.25
const STEP_SIZE = 64
const FLAG_WIDTH = 48
const GOAL_RESCHEDULE = 10
const PATIENCE_RESCHEDULE = 60
onready var hud = get_node("/root/GameScene/HUD")
onready var root_script = get_node("/root/GameScene")

var partner_name

# frame every second
var speed = 1
var step_delay = 0.2
var patience = PATIENCE_RESCHEDULE
var direction = Vector2(0, 0)

var is_being_hit = false

var colors = []
var goal

var next_step = Vector2(0, 0)
var old_step = Vector2(0, 0)

const N_SPRITE_TYPES = 3
var sprite_type = 1  # 1 to N_SPRITE_TYPES

var partner_driver
var partner_type

var just_turned = false

func init(name: String, new_loc: Vector2, dir: Vector2, driver, config: Dictionary):
	partner_type = PartnerType.new()
	partner_type.init(self, "random")

	partner_name = name
	partner_driver = driver

	position = new_loc
	old_step = position
	next_step = position
	direction = dir
	
	unpack_config(config)


func unpack_config(config: Dictionary):
	if "step_delay" in config:
		step_delay = config["step_delay"]
	if "speed" in config:
		speed = config["speed"]
	if "patience" in config:
		patience = config["patience"]


func random_color_choice(n_colors=2):
	# force duplicate
	var colors_tmp = ALL_COLORS + []
	# clear up previous colors
	colors = []
	for __ in range(n_colors):
		var color_i = randi() % colors_tmp.size()
		colors.append(colors_tmp.pop_at(color_i))


func random_goal_choice():
	goal = root_script.legit_goals[randi() % root_script.legit_goals.size()]
	$PatienceTimer.start()


func schedule_random_goal_choice():
	$PatienceTimer.stop()  # So you don't lose after satisfying
	$SatisfiedTween.interpolate_property($Sprite, "rotation_degrees",
		0, 360, 0.75,
		Tween.TRANS_CIRC, Tween.EASE_IN_OUT
	)
	$SatisfiedTween.start()
	$GoalRescheduleTimer.start(GOAL_RESCHEDULE)	
	goal = null


func die(reason):
	modulate = Color("#904949")
	if reason != null:
		get_parent().game_over(reason, partner_driver.get_num_partners(), position)


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
	
	$StepTimer.start(speed + step_delay)
	$PatienceTimer.start(patience)

	sprite_type = randi() % N_SPRITE_TYPES + 1
	reset_animation()

	# spawn animation
	# rotation
	$SatisfiedTween.interpolate_property(self, "rotation_degrees",
		0, 360, 0.75,
		Tween.TRANS_CIRC, Tween.EASE_IN_OUT
	)
	# scale
	$SatisfiedTween.interpolate_property(self, "scale",
		Vector2.ZERO, Vector2.ONE, 0.75,
		Tween.TRANS_CIRC, Tween.EASE_IN_OUT
	)
	$SatisfiedTween.start()


func _process(delta):
	# update patience bar
	$PatienceIndicator.rect_scale.x = 1 - $PatienceTimer.time_left/patience


func reset_animation():
	$AnimatedSprite.animation = "sprite%s" % sprite_type


func post_jump_callback():
	reset_animation()
	$WalkAudioStream.pitch_scale = 1


func _process_timestep():
	next_step += direction * STEP_SIZE
	$StepTween.interpolate_property(self, "position",
		old_step, next_step, speed * JUMP_TIME_COEF,
		Tween.TRANS_CIRC, Tween.EASE_IN_OUT)

	# Temporary, while the other sprite types are not available
	if sprite_type == 1:
		$AnimatedSprite.flip_h = direction[0] < 0
		$AnimatedSprite.play("sprite%s_walk" % sprite_type)

	if just_turned:
		# Make a high-pitched noise on the jump after a turn
		$WalkAudioStream.pitch_scale = 1.5
		just_turned = false

	$StepTween.interpolate_callback(self, speed * JUMP_TIME_COEF, "post_jump_callback")
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
		partner_type.collide_with_crossroads(other)
		if cur_direction != direction:
			just_turned = true
	elif other.is_in_group("places"):
		if other.place == goal:
			$PlaceEnteredAudioStream.play()
			schedule_random_goal_choice()


func mouse_entered():
	hud.update_partner_tracker(self)

func highlight_on(visible_val):
	$HighlightRect.visible = visible_val

func _on_GoalRescheduleTimer_timeout():
	random_goal_choice()

func _on_StepTimer_timeout():
	_process_timestep()

func _on_PatienceTimer_timeout():
	die("%s didn't get to %s in time" % [partner_name, goal.to_upper()])
