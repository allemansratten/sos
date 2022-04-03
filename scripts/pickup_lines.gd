class_name PickupLines

static func get_random_pickup_line_immut():
	return data[randi() % data.size()]

const data = [
	"heyy %s, are you free tonight?",
	"Can't wait to see you, %s!!",
	"Thinking about u %s uwu",
	"Wanna join me for dinner %s?",
	"Love you, %s",
	"I miss you, %s <3",
	"Thank you for being with me, %s",
]
