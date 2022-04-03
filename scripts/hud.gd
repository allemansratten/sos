extends CanvasLayer

func update_next_partner(spawn_time):
	$NextPartnerLabel.text = "Next partner in %ds" % [spawn_time]
	
func update_total_partner(count):
	$PartnerCount.text = str(count) + " partners"

func update_partner_tracker(new_partner):
	partner = new_partner
	delta_acc_info = INFO_VISIBILITY_DURATION

var partner = null
var delta_acc_info = 0
const INFO_VISIBILITY_DURATION = 5

func _process(delta):
	if partner != null and delta_acc_info >= 0:
		delta_acc_info -= delta
		$CharacterInfo.text = "%s wants to go to a %s (%ds)" % [
			partner.partner_name, partner.goal.to_upper(), partner.patience
		]
	else:
		$CharacterInfo.text = ""
