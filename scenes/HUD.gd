extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func update_next_partner_label(spawn_time):
	$NextPartnerLabel.text = "Next partner in %ds" % [spawn_time]
