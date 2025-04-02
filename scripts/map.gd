extends Node2D

@onready var BrickWallScene: PackedScene = preload("res://scenes/brick_wall.tscn") # <-- update path as needed

# Configurable parameters
const WALL_TILE_ID := 0 # Adjust this if your wall tile has a different ID
var brick_density := 0.4 # 0.0 to 1.0 (40% fill of valid spaces)

func _ready():
	var map_path = "res://scenes/maps/normal_map.tscn" if GameSettings.normal_level else "res://scenes/maps/alt_map.tscn"
	var map_scene = load(map_path)
	var map_instance = map_scene.instantiate()
	add_child(map_instance)
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
	place_brickwalls(empty_layer, player_zones_layer, wall_layer, map_instance)
	
func place_brickwalls(empty_layer: TileMapLayer, player_zones_layer: TileMapLayer, wall_layer: TileMapLayer, map_instance: Node):
	print("🚧 Starting brickwall placement...")
	var map_rect = empty_layer.get_used_rect()
	var map_size = map_rect.size
	var origin = map_rect.position
	var valid_positions: Array[Vector2i] = []

	# Loop through all cells in the used rectangle.
	for y in map_size.y:
		for x in map_size.x:
			var pos = origin + Vector2i(x, y)
			var empty_id = empty_layer.get_cell_source_id(pos)
			var player_zone_id = player_zones_layer.get_cell_source_id(pos)
			var wall_id = wall_layer.get_cell_source_id(pos)

			# Only consider positions where the "Empty" layer has a tile but the other layers are empty.
			if empty_id != -1 and player_zone_id == -1 and wall_id == -1:
				valid_positions.append(pos)

	print("✅ Found ", valid_positions.size(), " valid positions for brickwalls")
	valid_positions.shuffle()
	var brick_count = int(valid_positions.size() * brick_density)
	var selected = valid_positions.slice(0, brick_count)

	for pos in selected:
		var brick = BrickWallScene.instantiate()
		# Add brick as a child of map_instance so it inherits the proper scaling/position.
		map_instance.add_child(brick)
		# Use map_to_local() to get the centered position of the cell.
		var tile_local: Vector2 = empty_layer.map_to_local(pos)
		# Convert that local position to global coordinates.
		var world_pos: Vector2 = empty_layer.to_global(tile_local)
		# Finally, convert the global position into map_instance's local space.
		brick.position = map_instance.to_local(world_pos)
