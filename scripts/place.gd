extends Area2D

export(String) var place

func collide(partner):
	if place == partner.goal:
		print("satisfied partner's wish to go to ", place)
		partner
	print("colliding with partner", place, partner.goal)
