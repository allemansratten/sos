extends CanvasLayer

func update_next_partner(spawn_time):
	$NextPartnerLabel.text = "Next partner in %ds" % [spawn_time]
	
func update_total_partner(count):
	$PartnerCount.text = str(count) + " partners"

func update_partner_tracker(new_partner):
	# replace partner
	if partner != null:
		partner.highlight_on(false)
	partner = new_partner
	delta_acc_info = INFO_VISIBILITY_DURATION

var partner = null
var delta_acc_info = 0
const INFO_VISIBILITY_DURATION = 5

func _process(delta):
	if partner != null and delta_acc_info >= 0:
		delta_acc_info -= delta
		if partner.goal == null:
			$CharacterInfo.text = "%s is thinking about where to go" % [
				partner.partner_name
			]
		else:
			$CharacterInfo.text = "%s wants to go to a %s (%ds)" % [
				partner.partner_name, partner.goal.to_upper(), partner.patience
			]
		partner.highlight_on(true)
	else:
		if partner != null:
			partner.highlight_on(false)
			partner = null
		$CharacterInfo.text = ""
