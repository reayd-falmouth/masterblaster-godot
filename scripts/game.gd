extends Node2D

@onready var map_container: Node2D = $MapContainer
@onready var BrickWallScene: PackedScene = preload("res://scenes/brick_wall.tscn") # <-- update path as needed

# Configurable parameters
const WALL_TILE_ID := 0 # Adjust this if your wall tile has a different ID
var brick_density := 0.4 # 0.0 to 1.0 (40% fill of valid spaces)

func _ready():
	var map_path = "res://scenes/maps/normal_map.tscn" if GameSettings.normal_level else "res://scenes/maps/alt_map.tscn"
	var map_scene = load(map_path)
	var map_instance = map_scene.instantiate()
	map_container.add_child(map_instance)
	print("✅ Map scene instanced and added to map_container")

	await get_tree().process_frame # Allow scene to build

	var layers = map_instance.get_node("Layers")
	var empty_layer: TileMapLayer = layers.get_node("Empty")
	var player_zones_layer: TileMapLayer = layers.get_node("PlayerZones")
	var wall_layer: TileMapLayer = layers.get_node("Wall")

	if empty_layer == null or player_zones_layer == null or wall_layer == null:
		push_error("❌ One or more required TileMap layers are missing!")
		return

	print("🧱 Found all TileMap layers. Beginning brick placement...")
	place_brickwalls(empty_layer, player_zones_layer, wall_layer)

func _process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("Players")  # Ensure your group name matches exactly ('player' lowercase)
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


func place_brickwalls(empty_layer: TileMapLayer, player_zones_layer: TileMapLayer, wall_layer: TileMapLayer):
	print("🚧 Starting brickwall placement...")
	var map_rect = empty_layer.get_used_rect()
	var map_size = map_rect.size
	var origin = map_rect.position
	var valid_positions: Array[Vector2i] = []

	for y in map_size.y:
		for x in map_size.x:
			var pos = origin + Vector2i(x, y)

			var empty_id = empty_layer.get_cell_source_id(pos)
			var player_zone_id = player_zones_layer.get_cell_source_id(pos)
			var wall_id = wall_layer.get_cell_source_id(pos)

			# Only use positions where Empty has a tile, but other layers are empty
			if empty_id != -1 and player_zone_id == -1 and wall_id == -1:
				valid_positions.append(pos)

	print("✅ Found ", valid_positions.size(), " valid positions for brickwalls")

	valid_positions.shuffle()
	var brick_count = int(valid_positions.size() * brick_density)
	var selected = valid_positions.slice(0, brick_count)

	for pos in selected:
		var brick = BrickWallScene.instantiate()
		var world_pos = empty_layer.to_global(empty_layer.map_to_local(pos))
		brick.global_position = world_pos
		get_tree().current_scene.add_child(brick)
