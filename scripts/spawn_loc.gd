extends Node2D

# ask vilda why this is an integer and not a boolean
var free = 0

func area_entered(other):
	print("ENTERED", self, free)
	if other.is_in_group("partner"):
		free += 1

func area_exited(other):
	if other.is_in_group("partner"):
		free -= 1

func is_free():
	# if we're below 0 then something went very bad but better be permissive
	return free <= 0
