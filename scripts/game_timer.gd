extends Node

@export var alarm_player: AudioStreamPlayer  # Assign your AudioStreamPlayer node in the Inspector.
@export var game_duration: float = 30.0
@export var alarm_threshold: float = 10.0
@export var shrinking_enabled: bool = true

var remaining_time: float
var alarm_triggered: bool = false

func _ready():
	remaining_time = game_duration
	set_process(true)
	# Set the default background to black.
	RenderingServer.set_default_clear_color(Color.BLACK)

func _process(delta: float) -> void:
	remaining_time -= delta
	
	if shrinking_enabled and remaining_time <= alarm_threshold and not alarm_triggered:
		play_alarm()
		alarm_triggered = true

	# Once alarm is triggered, update the background every frame.
	if alarm_triggered:
		pulse_background_color()

	if remaining_time <= 0:
		end_game()

func pulse_background_color():
	# Calculate a pulsing factor using a sine wave.
	# Time.get_ticks_msec() returns the current time in milliseconds.
	var pulse = abs(sin(Time.get_ticks_msec() / 500.0))
	# Interpolate from black (0,0,0) to red (1,0,0) based on pulse value.
	RenderingServer.set_default_clear_color(Color(pulse, 0, 0))

func play_alarm():
	alarm_player.play()

func end_game():
	print("Game Over!")
	# Stop and free the alarm if it's playing.
	if alarm_player:
		alarm_player.stop()
		alarm_player.queue_free()

	set_process(false)
