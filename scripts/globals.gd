# globals.gd
extends Node

const BACKGROUND_COLOR = Color(0.0, 0.0, 0.0)
const FOREGROUND_COLOR = Color(1.0, 1.0, 1.0)
const PRIMARY_COLOR    = Color(0.0, 0.2, 1.0)
const SECONDARY_COLOR  = Color(0.333, 0.0, 0.733)
const BASE_FONT_SIZE: int = 26
var global_scale_factor: float = 1.0

func _ready():
	# Set full screen on startup.
	DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)

func _input(event):
	if event is InputEventKey and event.pressed:
		# Toggle full screen when F11 is pressed.
		if event.keycode == KEY_F11:
			var current_mode = DisplayServer.window_get_mode()
			if current_mode == DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
			else:
				DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)

func scale_sprite_to_window(sprite: Sprite2D) -> void:
	if not sprite or not sprite.texture:
		push_warning("Scaler: Sprite or texture is null.")
		return

	var window_size = DisplayServer.window_get_size()
	var texture_size = sprite.texture.get_size()
	var scale_factor = min(window_size.x / texture_size.x, window_size.y / texture_size.y)
	sprite.position = window_size / 2
	sprite.scale = Vector2(scale_factor, scale_factor)

# This function calculates a new font size based on a design resolution
# and updates the label's font size property.
func scale_bitmap_label_font(label: Label, base_font_size: int = BASE_FONT_SIZE, design_resolution: Vector2 = Vector2(1280,720)) -> void:
	if not label:
		push_warning("Globals: No label provided!")
		return

	var window_size = DisplayServer.window_get_size()
	var scale_factor = min(window_size.x / design_resolution.x, window_size.y / design_resolution.y)
	var new_font_size = int(base_font_size * scale_factor)
	
	# Attempt to update the font size on the bitmap font.
	# Note: With a BitmapFont, this may only change the reported value and not the actual rendering.
	label.label_settings.font_size = new_font_size
	print("Updated font size to: ", new_font_size)

func go_to_next_scene(scene_path: String):
	# Change the scene to your next screen.
	get_tree().change_scene_to_file(scene_path)

# Returns true if the input event should trigger a scene change.
func is_next_scene_input(event: InputEvent) -> bool:
	# For keyboard input: accept Space or Enter.
	if event is InputEventKey:
		if event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER):
			return true
	# For mouse input: any pressed mouse button.
	elif event is InputEventMouseButton:
		if event.pressed:
			return true
	# For joypad input: any pressed button.
	elif event is InputEventJoypadButton:
		if event.pressed:
			return true
	return false
