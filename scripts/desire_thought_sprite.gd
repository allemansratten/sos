extends Node2D

var low_patience = false
var has_goal = true


func _on_ThoughtTimer_timeout():
	if low_patience:
		self_modulate = Color(1, 0.3, 0.3)
		self.show()
	elif self.is_visible_in_tree():
		self.hide()
	elif has_goal:
		self.show()


# Show angry label when low patience
func _on_Partner_low_patience():
	low_patience = true
	_on_ThoughtTimer_timeout()


# Hide thoughts when goal is satisfied
func _on_Partner_goal_satisfied():
	has_goal = false
	low_patience = false
	self.hide()


# When new goal is generated, display thought
func _on_GoalRescheduleTimer_timeout():
	has_goal = true
	self.show()
