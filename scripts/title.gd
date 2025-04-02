extends Control

@onready var sprite = $CenterContainer/Sprite2D
var scene: String = "res://scenes/credits.tscn"

func _ready():
	# Hide the mouse cursor.
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Globals.scale_sprite_to_window(sprite)

func _notification(what):
	# When the window is resized, update the sprite.
	if what == NOTIFICATION_RESIZED:
		Globals.scale_sprite_to_window(sprite)

func _input(event):
	# Check for any key, mouse, or joypad input except F11.
	if Globals.is_next_scene_input(event):
		Globals.go_to_next_scene(scene)
