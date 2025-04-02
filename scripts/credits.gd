extends Control

@onready var label = $CenterContainer/Label
var scene: String = "res://scenes/menu.tscn"

func _ready():
	Globals.scale_bitmap_label_font(label)

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		Globals.scale_bitmap_label_font(label)
		
func _input(event):
	# Listen for any key, mouse, or joypad input.
	if Globals.is_next_scene_input(event):
		Globals.go_to_next_scene(scene)
