extends Node2D  # or extends Control if using UI

# Optionally, preload your next scene if you prefer
# var next_scene = preload("res://NextScene.tscn")

func _ready():
	# Get the size of the viewport (i.e., the game window)
	var viewport_size = get_viewport_rect().size
	var texture_size = $Sprite2D.texture.get_size()
	# Any initialization code goes here (e.g., hiding the mouse cursor)
	# For example, if you want to hide the mouse cursor:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	# Set the Sprite's position to the center of the viewport
	$Sprite2D.position = viewport_size / 2
	var scale_factor = min(viewport_size.x / texture_size.x, viewport_size.y / texture_size.y)
	$Sprite2D.scale = Vector2(scale_factor, scale_factor)
	
func _input(event):
	# Check if any input event (key, mouse button, or joypad button) is pressed.
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		if event.pressed:
			_go_to_next_scene()

func _go_to_next_scene():
	# Change the scene to your next screen. Update the path accordingly.
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
