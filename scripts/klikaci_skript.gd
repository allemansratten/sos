extends RichTextLabel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print("hello na _ready? dispatcher: ", self, " konec")
	self.add_text("[ěščěž]")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
