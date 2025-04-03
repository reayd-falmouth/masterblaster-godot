extends RigidBody2D
class_name Bomb

@export var is_timebomb: bool = false
@export var timer_duration: float = 3.0
@export var explosion_size: int = 3  # How many tiles the explosion reaches
@export var explosion_sound: AudioStream  # Assign your explosion sound in the editor
@export var tile_size: int = 16  # Size of one tile in pixels

# Preload the ExplosionSpawner scene/script (or load it via script)
var FIREBALL_SPAWNER = preload("res://scenes/fireball_spawner.tscn")
var FIREBALL = preload("res://scenes/fireball.tscn")

var bomb_timer: Timer
var collision_enabled: bool = false  # Track if the collision has been enabled

func _ready():	
	# Freeze the bomb so that it doesn't move.
	freeze = true

	# Disable the collision shape initially.
	$CollisionShape2D.disabled = true
	set_process(true)  # Enable _process for the overlap check
	
	# If this bomb isn't a timebomb, start a timer to trigger the explosion.
	if not is_timebomb:
		bomb_timer = Timer.new()
		bomb_timer.wait_time = timer_duration
		bomb_timer.one_shot = true
		bomb_timer.autostart = true
		bomb_timer.timeout.connect(explode)
		add_child(bomb_timer)

func _process(dt: float) -> void:
	if not collision_enabled:
		# Create a physics query for our collision shape.
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsShapeQueryParameters2D.new()
		query.shape = $CollisionShape2D.shape
		query.transform = global_transform
		query.collide_with_bodies = true
		query.exclude = [self]
		# Check for overlapping bodies.
		var result = space_state.intersect_shape(query, 10)
		var overlapping_player = false
		for res in result:
			# If any collider is a Player, then still overlapping.
			if res.collider is Player:
				overlapping_player = true
				break
		# If no Player is overlapping, re-enable collision.
		if not overlapping_player:
			$CollisionShape2D.disabled = false
			collision_enabled = true
	
func explode():
	# Play explosion sound.
	if explosion_sound:
		var sound_player = AudioStreamPlayer2D.new()
		sound_player.stream = explosion_sound
		get_tree().root.add_child(sound_player)
		sound_player.play()

	# Create the central explosion effect.
	var central_explosion = FIREBALL.instantiate()
	central_explosion.position = position
	get_parent().add_child(central_explosion)

	# Create an ExplosionSpawner for delayed fireballs.
	var spawner = FIREBALL_SPAWNER.instantiate()
	get_parent().add_child(spawner)

	# Calculate the effective tile size using the parent's scale.
	var parent = get_parent()
	var effective_tile_size = tile_size * parent.scale.x

	# Determine the bomb's grid coordinate.
	var bomb_grid = Vector2(
		round(position.x / effective_tile_size),
		round(position.y / effective_tile_size)
	)

	# Propagate explosion in the four cardinal directions.
	for direction in [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]:
		for i in range(1, explosion_size):
			# Calculate the target grid cell.
			var target_grid = bomb_grid + direction * i
			# Convert grid cell to world position (center of the cell).
			var target_world_pos = target_grid * effective_tile_size + Vector2(effective_tile_size * 0.5, effective_tile_size * 0.5)
			
			# Check the cell using grid-based logic.
			# If a block is found, destroy it (if destructible) and break propagation.
			if check_and_handle_block(target_grid, effective_tile_size):
				break

			# Spawn the fireball effect at the center of the cell.
			var delay = i * 0.10
			spawner.spawn_fireball(target_world_pos, delay)
			
	queue_free()  # Remove the bomb.


# Called externally when the remote control attribute is active.
func enable_remote_control():
	freeze = false

# For timebomb-type bombs: call this when the player releases the place_bomb input.
func trigger_timebomb():
	if is_timebomb:
		if bomb_timer and not bomb_timer.is_stopped():
			bomb_timer.stop()
		explode()

func is_space_free_in_rect(position: Vector2, size: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var rect_shape = RectangleShape2D.new()
	# The RectangleShape2D uses extents (half the size).
	rect_shape.extents = size / 2
	query.shape = rect_shape
	query.transform = Transform2D(0, position)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	# Optionally, exclude the bomb that’s spawning the explosion:
	query.exclude = [self]
	
	var result = space_state.intersect_shape(query)
	# Filter out bodies that are bombs or players, so they don't block propagation.
	for r in result:
		var collider = r.collider
		# If collider is a Bomb or a Player, ignore it:
		if collider is Bomb or collider is Player:
			continue
		# If it is anything else, consider the space blocked.
		return false
	return true

# Checks if the given grid cell is blocked by a destructible object.
func is_grid_blocked(grid_cell: Vector2, effective_tile_size: float) -> bool:
	# Convert the grid cell to an integer coordinate.
	var cell_coords = Vector2i(round(grid_cell.x), round(grid_cell.y))
	
	# Get all nodes in the "indestructible" group.
	# (This group should include your wall layer node.)
	var tilemaps = get_tree().get_nodes_in_group("indestructible")
	# Loop through each tile map and check if the cell contains a wall tile.
	for tilemap in tilemaps:
		# If the wall exists in this cell, get_cell_source_id() should not return -1.
		if tilemap.get_cell_source_id(cell_coords) != -1:
			return true
	
		# First, check for destructible objects.
	var destructibles = get_tree().get_nodes_in_group("destructible")
	for obj in destructibles:
		# Compute the object's grid coordinate based on its position.
		var obj_grid = Vector2i(round(obj.position.x / effective_tile_size), round(obj.position.y / effective_tile_size))
		if obj_grid == cell_coords:
			# Destroy the destructible object and block further propagation.
			if obj.has_method("destroy"):
				obj.destroy()

			return true
	
	return false
	
func check_and_handle_block(grid_cell: Vector2, effective_tile_size: float) -> bool:
	# Convert explosion grid cell to integer coordinates.
	var cell_coords = Vector2i(round(grid_cell.x), round(grid_cell.y))
	
	# Get all nodes in the "indestructible" group.
	# (This group should include your wall layer node.)
	var tilemaps = get_tree().get_nodes_in_group("indestructible")
	# Loop through each tile map and check if the cell contains a wall tile.
	for tilemap in tilemaps:
		# If the wall exists in this cell, get_cell_source_id() should not return -1.
		if tilemap.get_cell_source_id(cell_coords) != -1:
			return true
	
	# First, check for destructible objects.
	var destructibles = get_tree().get_nodes_in_group("destructible")
	for obj in destructibles:
		# Compute the object's grid coordinate.
		var obj_grid = Vector2i(round(obj.position.x / effective_tile_size), round(obj.position.y / effective_tile_size))
		if obj_grid == cell_coords:
			# Destroy the object.
			if obj.has_method("destroy"):
				obj.destroy()

			# Stop propagation in this direction.
			return true
		
	# Nothing is blocking this cell.
	return false
