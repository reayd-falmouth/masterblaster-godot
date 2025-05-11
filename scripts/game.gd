extends Control

@onready var map_container: Node2D = $CenterContainer/MapContainer
@onready var BrickWallScene: PackedScene = preload("res://scenes/brick_wall.tscn") # <-- update path as needed

# Configurable parameters
const WALL_TILE_ID := 0 # Adjust this if your wall tile has a different ID
var brick_density := 0.4 # 0.0 to 1.0 (40% fill of valid spaces)
# Set the resolution you designed for (e.g., 1280x720)
const DESIGN_RESOLUTION: Vector2 = Vector2(1280, 720)

func _ready():
	get_viewport().connect("size_changed", Callable(self, "_on_window_resized"))
	_resize_canvas()
	
func _on_window_resized():
	_resize_canvas()

func _process(delta: float) -> void:

	var players = get_tree().get_nodes_in_group("player")  # Ensure your group name matches exactly ('player' lowercase)
	var alive_count = 0
	for player in players:
		if not player.is_dead:
			alive_count += 1
	
	if alive_count <= 1:
		set_process(false)  # Stop further checks to avoid repeat calls
		game_over()

func game_over():
	print("🎯 Game over! Too few players left to continue.")
	await get_tree().create_timer(3).timeout
	
	# Gather all players that are not dead (i.e., still alive)
	var alive_players = []
	for player in get_tree().get_nodes_in_group("Players"):
		if not player.is_dead:
			alive_players.append(player)
	
	# Update the player stats for each alive player
	# (Assumes each player has a 'player_index' property corresponding to their index in PlayerStats.players_data)
	for player in alive_players:
		PlayerStats.add_win(player.player_index)
	
	# Check if any player's wins have reached the threshold for game over.
	for player_stat in PlayerStats.players_data:
		if player_stat["wins"] >= GameSettings.wins_needed:
			get_tree().change_scene_to_file("res://scenes/overs.tscn")  # Update path as needed
			return
	
	# If no player has reached the win threshold, go to the standings scene.
	get_tree().change_scene_to_file("res://scenes/standings.tscn")  # Update path as needed

func _resize_canvas():
	# Get the current window size
	var window_size: Vector2 = DisplayServer.window_get_size()
	
	# Calculate a uniform scale factor while preserving the aspect ratio.
	# Using min() will ensure the entire design is visible with letterboxing if needed.
	var scale_factor: float = min(window_size.x / DESIGN_RESOLUTION.x, window_size.y / DESIGN_RESOLUTION.y)
	
	# Scale the entire CanvasLayer
	self.scale = Vector2(scale_factor, scale_factor)
	
	Globals.global_scale_factor = scale_factor
