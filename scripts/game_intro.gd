extends Node

export(PackedScene) var MessageComplex

# Called when the node enters the scene tree for the first time.
func _ready():
	add_message("Hey hunny, is today still on?", 1, false)
	add_message("why sure!", 1, true)
	add_message("Looking forward!", 1, false)
	add_message("me too :)", 1, true)
		
	add_message("sup bae! wanna hang out at\nmine tonight?", 2, false)
	add_message("that'd be AMAZING!", 2, true)
	add_message("see you at 8", 2, false)
	
	add_message("are you free tonight?", 3, true, 1.5)
	add_message("Yeah sure", 3, false, 0.5)
	add_message("how about we just chill at\nthe gallery?", 3, true, 0.5)
	add_message("need to pick up my books before", 3, false, 0.5)
	add_message("np, see you there later?", 3, true, 0.5)
	add_message("Alrighty <3", 3, false, 0.5)
	
	add_message("do you feel like going to the disco\nw/ me??", 4, false, 1)
	add_message("I'm sorta busy tonight :((", 4, true, 0.4)
	add_message("pleaase can't you make time?", 4, false, 0.4)
	add_message("alright, love you", 4, true, 0.4)
	
	add_message("can you make it this evening?", 5, false, 1)
	add_message("thinking about you", 6, false, 0.3)
	add_message("excited about tonight!", 7, false, 0.3)
	add_message("thanks for seeing me love", 8, false, 0.3)
	add_message("love you", 9, false, 0.3)
	add_message("i love you too", 9, true, 0.3)
	add_message("hey I bumped into your ex today\nare you still seeing them?", 10, false, 0.3)
	add_message("What do you want to get for dinner?", 11, false, 0.3+1)
	add_message("idk, what were you thinking about?", 12, true, 0.3)
	add_message("Heyyy darling I'm kinda down tonight\ncould you come over please?", 13, false, 0.3)
	add_message("Sure, I'm right there!", 14, true, 0.3)
	
	add_message("sweetheart, are you seeing other people?", 15, false, 0.8)
	add_message("is there something you're not telling me?", 16, false, 0.7)
	add_message("I wanted to ask you if you were ever\ndishonest with me", 17, false, 0.7)
	
	yield(get_tree().create_timer(delay_acc+2), "timeout")
	
	$Notification.play()
	$Instructions.visible = true
	$ButtonSkip.queue_free()
	
# wtf gdscript doesn't have an array initializer
var msg_counts = [0,0,0,0,0,0,0]
var msg_counts_newline = [0,0,0,0,0,0,0]
const MSG_SENDER = [null, "Ashley", "Emery", "Nova", "Milan", ""]

var delay_acc = 0

func add_message(info: String, parent_i, sender_me=false, delay=1):
	delay_acc += delay
	
	var parent = find_node("M%d" %parent_i)
	
	# TODO: notification sound
	var message = MessageComplex.instance()
	
	if sender_me:
		message.find_node("MessageLeft").queue_free()
		message.find_node("LabelRight").text = info
		message.position.x = 250
	else:
		message.find_node("MessageRight").queue_free()
		message.find_node("LabelLeft").text = info
		message.position.x = 10
	
	if parent_i <= 4:
		message.position.y = msg_counts[parent_i]*40 + msg_counts_newline[parent_i]*20
		msg_counts[parent_i] += 1
		msg_counts_newline[parent_i] += info.count("\n")
		
	message.z_index = parent_i
		
	yield(get_tree().create_timer(delay_acc), "timeout")
	if parent_i <= 4:
		parent.find_node("Sender").text = MSG_SENDER[parent_i]
	parent.add_child(message)
	if not sender_me:
		$Notification.play()
	


func start_button_pressed():
	get_tree().change_scene("res://scenes/Game.tscn")
