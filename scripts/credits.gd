extends Control

func _ready():
	# Create a new Label node
	var credits_label = $CenterContainer/Label
	# Enable text wrapping so that long lines adjust to the window size
	#credits_label.autowrap_mode = true
	
func _input(event):
	# Listen for any key, mouse, or joypad input.
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		if event.pressed:
			_go_to_next_scene()

func _go_to_next_scene():
	# Change the scene to your next screen.
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
