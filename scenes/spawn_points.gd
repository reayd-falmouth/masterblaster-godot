extends Node

@export var player_scene: PackedScene  # Reference the Player scene from the editor

var spawn_positions = {}

func _ready():
	spawn_positions = {
		"top_left": $SpawnTopLeft.global_position,
		"top_right": $SpawnTopRight.global_position,
		"bottom_left": $SpawnBottomLeft.global_position,
		"bottom_right": $SpawnBottomRight.global_position,
		"center": $SpawnCenter.global_position,
	}

	spawn_players(GameSettings.players)  # Replace '4' with actual player count dynamically

func spawn_players(player_count):
	var positions = []
	match player_count:
		2:
			positions = ["top_left", "bottom_right"]
		3:
			positions = ["top_left", "bottom_right", "center"]
		4:
			positions = ["top_left", "top_right", "bottom_left", "bottom_right"]
		5:
			positions = ["top_left", "top_right", "bottom_left", "bottom_right", "center"]

	for i in range(player_count):
		var player_instance = player_scene.instantiate()
		player_instance.global_position = spawn_positions[positions[i]]
		player_instance.player_number = i + 1  # Assigning a unique ID for each player
		#player_instance.set_character_sprite("player_red") # Customize per your logic
		$Players.add_child(player_instance)
