extends Node2D

var low_patience = false
var has_goal = true


func _on_ThoughtTimer_timeout():
	if not has_goal:
		self.hide();
	elif low_patience:
		self_modulate = Color(1, 0.3, 0.3)
		self.show()
	elif self.is_visible_in_tree():
		self.hide()
	else:
		self_modulate = Color(1, 1, 1)
		self.show()


# Show angry label when low patience
func _on_PatienceTimer_low_patience():
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
	_on_ThoughtTimer_timeout()
