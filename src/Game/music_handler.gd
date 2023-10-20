extends Node
@export var music_tracks:Array[AudioStreamWAV]
func _ready():
	shuffle()

func shuffle():
	randomize()
	var random_track = music_tracks.pick_random()
	$AudioStreamPlayer2D.set_stream(random_track)
	$AudioStreamPlayer2D.play()
func _on_audio_stream_player_2d_finished():
	shuffle()
	pass # Replace with function body.
