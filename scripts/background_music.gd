# BackgroundMusic.gd
extends Node

@export var music_player: AudioStreamPlayer  # Assign your AudioStreamPlayer node in the Inspector.
@export var initial_pitch: float = 1.5
@export var final_pitch: float = 2.0
@export var tension_duration: float = 120.0  # Time (in seconds) to reach the final pitch

var elapsed_time: float = 0.0

func _process(delta: float) -> void:
	elapsed_time += delta
	# Calculate a normalized value between 0 and 1.
	var t = clamp(elapsed_time / tension_duration, 0, 1)
	# Lerp between the initial and final pitch.
	music_player.pitch_scale = lerp(initial_pitch, final_pitch, t)
