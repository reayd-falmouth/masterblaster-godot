# Standings.gd
extends Control

@onready var label = $VBoxContainer/Label
@onready var player_rows_container = $PlayerRowsContainer  # GridContainer for dynamic icons

@export var bingo_sound: AudioStream  # Assign your death sound in the editor
var countdown_scene: String = "res://scenes/countdown.tscn"
var shop_scene: String = "res://scenes/shop.tscn"
var wheel_scene: String = "res://scenes/wheel.tscn"
var player_scene = preload("res://scenes/player.tscn")

# Adjust this scale factor to suit your UI design
var icon_scale: Vector2 = Vector2(3, 3)

func _ready():
	Globals.scale_bitmap_label_font(label)
	
	var sound_player = AudioStreamPlayer2D.new()
	sound_player.stream = bingo_sound
	get_tree().root.add_child(sound_player)
	sound_player.play()

	_set_player_icons()
	
	await get_tree().create_timer(3.0).timeout
	
	if GameSettings.shop:
		if GameSettings.gambling:
			Globals.go_to_next_scene(wheel_scene)
		else:
			Globals.go_to_next_scene(shop_scene)
	else:
		Globals.go_to_next_scene(countdown_scene)

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		Globals.scale_bitmap_label_font(label)

func _set_player_icons():
	# Loop over all rows in the container
	for i in range(player_rows_container.get_child_count()):
		var row = player_rows_container.get_child(i)
		# Enable only if this row index is less than active players
		row.visible = (i < GameSettings.players)
		
		# Optionally, if the row holds a player icon that you want to update:
		if row.visible:
			# Assuming each row has a child node "PlayerIcon" and we want to update it
			var player_icon = row.get_node("player%d" % i)
			# Set player number (adjust as needed, e.g. row index + 1)
			#player_icon.player_number = i + 1
			## Update the icon's animation to idle (ensuring the node is ready)
			#player_icon.call_deferred("update_animation", false)
			## Apply scaling if necessary (using your global scale factor)
			#player_icon.scale = icon_scale * Globals.global_scale_factor
			## Disable any unnecessary processing
			#player_icon.set_process(false)
			#player_icon.set_physics_process(false)
