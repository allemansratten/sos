extends Timer

onready var hud = get_node("/root/GameScene/HUD")

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	hud.update_next_partner(time_left)
