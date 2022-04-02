extends Node2D

const ALL_COLORS = ["red", "green", "blue", "pink", "yellow", "blankytněmodrájakobarvavýchodobrněnskéhopotokaránopolehounkémdešti"]
const ALL_GOALS = ["cafe", "cinema", "park", "library", "gallery", "disco"]


var colors = []
var goal
var patience = 2.0

func random_color_choice(n_colors=2):
	var colors_tmp = ALL_COLORS
	# clear up previous colors
	colors = []
	for i in range(n_colors):
		var color_i = randi() % colors_tmp.size()
		print(color_i)
		colors.append(colors_tmp.pop_at(color_i))

func random_goal_choice():
	goal = ALL_GOALS[randi() % ALL_GOALS.size()]

# Called when the node enters the scene tree for the first time.
func _ready():
	random_color_choice(2)
	random_goal_choice()
	prints(colors, goal)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	patience -= delta
	if patience <= 0:
		# TODO: this will break when the parent is not the node with game_over function
		get_parent().game_over("patience")
	else:
		print(patience)
