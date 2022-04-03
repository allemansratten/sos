tool # spusti kod i v editoru
extends Area2D

enum CrossroadDirection {
	LEFT, RIGHT, UP, DOWN, CONTINUE, BEND1, BEND2
}

export(CrossroadDirection) var direction = CrossroadDirection.LEFT
var rendered_direction = CrossroadDirection.LEFT
export(bool) var locked = false

const DIRECTION_TO_DEGREES = {
	CrossroadDirection.LEFT: 180,
	CrossroadDirection.RIGHT: 0,
	CrossroadDirection.UP: -90,
	CrossroadDirection.DOWN: 90,
}

var enabled_arr = []
var enabled_i = 0
export(bool) var enable_left = true
export(bool) var enable_right = true
export(bool) var enable_up = true
export(bool) var enable_down = true
export(bool) var enable_continue = true
export(bool) var enable_bend_1 = true
export(bool) var enable_bend_2 = true

func _ready():
	# ask vilda why we need this stupid code
	if enable_right:
		enabled_arr.append(CrossroadDirection.RIGHT)
	if enable_left:
		enabled_arr.append(CrossroadDirection.LEFT)
	if enable_up:
		enabled_arr.append(CrossroadDirection.UP)
	if enable_down:
		enabled_arr.append(CrossroadDirection.DOWN)
	if enable_bend_1:
		enabled_arr.append(CrossroadDirection.BEND1)
	if enable_bend_2:
		enabled_arr.append(CrossroadDirection.BEND2)
	if enable_continue:
		enabled_arr.append(CrossroadDirection.CONTINUE)
	render_arrows()
		
func render_arrows():
	rendered_direction = direction
	if direction == CrossroadDirection.CONTINUE:
		$ArrowSprite.frame = 0
	elif direction == CrossroadDirection.BEND1:
		$ArrowSprite.frame = 2
	elif direction == CrossroadDirection.BEND2:
		$ArrowSprite.frame = 3
	else:
		$ArrowSprite.frame = 1
		$ArrowSprite.rotation_degrees = DIRECTION_TO_DEGREES[direction]
		
	if locked:
		$ArrowSprite.modulate = Color("a7a7a7")
	else:
		$ArrowSprite.modulate = Color("ffffff")
	
func get_output_direction(in_direction: Vector2):
	if direction == CrossroadDirection.CONTINUE:
		return in_direction
	elif direction == CrossroadDirection.BEND1:
		if in_direction == Vector2.UP:
			return Vector2.RIGHT
		elif in_direction == Vector2.LEFT:
			return Vector2.DOWN
		elif in_direction == Vector2.DOWN:
			return Vector2.LEFT
		elif in_direction == Vector2.RIGHT:
			return Vector2.UP
	elif direction == CrossroadDirection.BEND2:
		if in_direction == Vector2.UP:
			return Vector2.LEFT
		elif in_direction == Vector2.LEFT:
			return Vector2.UP
		elif in_direction == Vector2.DOWN:
			return Vector2.RIGHT
		elif in_direction == Vector2.RIGHT:
			return Vector2.DOWN
	elif direction == CrossroadDirection.RIGHT:
		return Vector2(1, 0)
	elif direction == CrossroadDirection.LEFT:
		return Vector2(-1, 0)
	elif direction == CrossroadDirection.UP:
		return Vector2(0, -1)
	elif direction == CrossroadDirection.DOWN:
		return Vector2(0, 1)
	else:
		printerr("Undefined output direction")
		return in_direction

func _process(_delta):
	# hack to make it work in the editor
	if rendered_direction != direction:
		render_arrows()

func on_click():
	if locked:
		return

	$OnClickAudioStream.play()

	enabled_i = (enabled_i + 1) % enabled_arr.size()
	direction = enabled_arr[enabled_i]
	render_arrows()


func mouse_enter():
	if not locked:
		$HighlightRect.visible = true
	
func mouse_exit():
	$HighlightRect.visible = false


func mouse_input(event):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.pressed:
		self.on_click()
	pass # Replace with function body.
