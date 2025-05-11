# Standings.gd
extends Control

@onready var label = $VBoxContainer/Label

@export var bingo_sound: AudioStream  # Assign your death sound in the editor
var shop_scene: String = "res://scenes/shop.tscn"

func _ready():
	Globals.scale_bitmap_label_font(label)
	var sound_player = AudioStreamPlayer2D.new()
	sound_player.stream = bingo_sound
	get_tree().root.add_child(sound_player)
	sound_player.play()
	
	await get_tree().create_timer(3.0).timeout

	Globals.go_to_next_scene(shop_scene)

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		Globals.scale_bitmap_label_font(label)
