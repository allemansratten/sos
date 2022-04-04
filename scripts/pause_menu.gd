extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Control.hide()

onready var player = get_node("/root/GameScene/MusicPlayer")
var muted = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	var now_paused = not get_tree().paused
	get_tree().paused = now_paused

	if now_paused:
		$Control.show()
		player.volume_db = -8
	else:
		$Control.hide()
		player.volume_db = 0


func _on_UnpauseButton_pressed():
	toggle_pause()


var music_position = 0

func _on_MuteButton_pressed():
	muted = not muted
	if muted:
		$Control.get_node("MuteButton").text = "unmute"
		music_position = player.get_playback_position()
		player.stop()
	else:
		$Control.get_node("MuteButton").text = "mute"
		
		player.play(music_position)
