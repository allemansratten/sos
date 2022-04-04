extends Timer

signal start_step(speed)

var standing = false
var speed
var delay


func init(spd, step_delay):
	speed = spd
	delay = step_delay
	start(speed)


# Toggle between waiting and walking
func _on_StepTimer_timeout():
	if standing:
		start(speed)
	else:
		emit_signal("start_step", speed)
		start(delay)
	standing = not standing
