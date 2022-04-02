extends Area2D

export(String) var place

func collide(partner):
	print("colliding with partner", place, partner.goal)
