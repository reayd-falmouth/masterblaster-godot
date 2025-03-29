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

# Helper function to check if space is free in a small circle.
func is_space_free_in_circle(position: Vector2, radius: float) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = radius
	query.shape = circle_shape
	query.transform = Transform2D(0, position)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var result = space_state.intersect_shape(query)
	return result.size() == 0

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

			
func _ready():
	# Freeze the bomb so that it doesn't move.
	freeze = true

	# If this bomb isn't a timebomb, start a timer to trigger the explosion.
	if not is_timebomb:
		bomb_timer = Timer.new()
		bomb_timer.wait_time = timer_duration
		bomb_timer.one_shot = true
		bomb_timer.autostart = true
		bomb_timer.timeout.connect(explode)
		add_child(bomb_timer)

func explode():
	# Play the explosion sound.
	if explosion_sound:
		var sound_player = AudioStreamPlayer2D.new()
		sound_player.stream = explosion_sound
		get_tree().root.add_child(sound_player)
		sound_player.play()

	# Create and add the central explosion effect immediately.
	var central_explosion = FIREBALL.instantiate()
	central_explosion.position = position
	get_tree().root.add_child(central_explosion)

	# Create an ExplosionSpawner so that delayed fireballs can be spawned even after the bomb is freed.
	var spawner = FIREBALL_SPAWNER.instantiate()
	get_tree().root.add_child(spawner)

	var check_size = Vector2(tile_size - 1, tile_size - 1)
	# Propagate the explosion in the four cardinal directions.
	for direction in [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]:
		for i in range(1, explosion_size):
			var target_position = position + direction * (i * tile_size)
			if not is_space_free_in_rect(target_position, check_size):
				break
			var delay = i * 0.10  # Delay increases with distance.
			spawner.spawn_fireball(target_position, delay)
			
	queue_free()  # Remove the bomb from the scene.

# Called externally when the remote control attribute is active.
func enable_remote_control():
	freeze = false

# For timebomb-type bombs: call this when the player releases the place_bomb input.
func trigger_timebomb():
	if is_timebomb:
		if bomb_timer and not bomb_timer.is_stopped():
			bomb_timer.stop()
		explode()
