extends CanvasLayer

export(PackedScene) var off_screen_marker_scene


func update_next_partner(spawn_time):
	# The `max` prevents a 0 from appearing for 1 frame
	$NextPartnerLabel.text = "Next partner in %ds" % [max(ceil(spawn_time), 1)]

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
export(PackedScene) var MessageScene
const INFO_VISIBILITY_DURATION = 5
const MESSAGE_DURATION = 10

var active_messages = []

func send_pickup_line(partner_name):
	var message = MessageScene.instance()
	var info = PickupLines.get_random_pickup_line_immut() % partner_name.capitalize()
	message.find_node("MessageLabel").text = info
	$Messages.add_child(message)
	active_messages.append([message, MESSAGE_DURATION])

func _process(delta):
	if partner != null and delta_acc_info >= 0:
		delta_acc_info -= delta
		var extra = ""
		if partner.goal == null:
			$CharacterInfo.text = "%s is thinking about where to go%s" % [
				partner.partner_name, extra,
			]
		else:
			$CharacterInfo.text = "%s wants to go to a %s (%ds)%s" % [
				partner.partner_name,
				partner.goal.to_upper(),
				partner.get_node("PatienceTimer").time_left,
				extra,
			]
		partner.highlight_on(true)
	else:
		if partner != null:
			partner.highlight_on(false)
			partner = null
		$CharacterInfo.text = ""
		
	# reorganize messages
	var offset_i = 0
	
	for msg_i in range(len(active_messages)):
		active_messages[msg_i-offset_i][1] -= delta
		if active_messages[msg_i-offset_i][1] <= 0:
			# remove message
			active_messages.pop_at(msg_i-offset_i)[0].queue_free()
			offset_i += 1
		else:
			# reposition
			# once offset_i > 0 all the messages are removed and this is suboptimal
			active_messages[msg_i-offset_i][0].offset.y = (msg_i-offset_i)*30
			active_messages[msg_i-offset_i][0].offset.x = $Messages.position.x

	update_off_screen_markers()


var off_screen_markers = []

func update_off_screen_markers():
	var partners = get_tree().get_nodes_in_group("partner")

	while len(off_screen_markers) < len(partners):
		# Assumes the nodes in the group are in a fixed order - does this make sense?
		var marker = off_screen_marker_scene.instance()
		marker.partner = partners[len(off_screen_markers)]
		off_screen_markers.append(marker)
		add_child(marker)
