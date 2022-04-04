extends Timer

signal low_patience

var signaled_low_patience = false

func _process(_delta):
	if not signaled_low_patience and time_left < 15:
		signaled_low_patience = true
		emit_signal("low_patience")


func _on_Partner_goal_satisfied():
	stop()


func _on_GoalRescheduleTimer_timeout():
	signaled_low_patience = false
