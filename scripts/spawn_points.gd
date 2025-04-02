extends Node2D

@export var player_scene: PackedScene  # Reference the Player scene from the editor

var spawn_positions = {}

func _ready():
	# Store the global positions from your spawn marker nodes.
	spawn_positions = {
		"top_left": $SpawnTopLeft.global_position,
		"top_right": $SpawnTopRight.global_position,
		"bottom_left": $SpawnBottomLeft.global_position,
		"bottom_right": $SpawnBottomRight.global_position,
		"center": $SpawnCenter.global_position,
	}
	
	spawn_players(GameSettings.players)  # Dynamically pass player count

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

	# Loop over each player to spawn
	for i in range(player_count):
		var player_instance = player_scene.instantiate()
		# Convert the stored global spawn position into the local coordinate space
		# of the $Players container.
		var spawn_global = spawn_positions[positions[i]]
		var spawn_local = $Players.to_local(spawn_global)
		player_instance.position = spawn_local
		# If the players appear too small, adjust their scale here:
		# For example, if you have a global scaling factor (say, computed in your UI scaling code):
		# player_instance.scale = your_scale_factor * player_instance.scale
		player_instance.player_number = i + 1  # Unique player ID
		$Players.add_child(player_instance)
