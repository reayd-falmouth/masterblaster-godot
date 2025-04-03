extends Node

class_name BombPlacementSystem 

const BOMB_SCENE = preload("res://scenes/bomb.tscn")

var player: Player = null
var bombs_placed = 0
var timebomb_bombs: Array = []   # To track remote (timebomb) bombs

func _ready() -> void:
	player = get_parent()

func place_bomb(timebomb: bool):
	if bombs_placed == player.bombs:
		return

	var bomb = BOMB_SCENE.instantiate()
	bomb.is_timebomb = timebomb
	bomb.explosion_size = player.power

	var parent = player.get_parent()
	var local_pos = parent.to_local(player.global_position)

	# Use the parent's actual scale if needed.
	var effective_scale = parent.scale.x  # Assuming uniform scaling.
	var tile_size = Globals.TILE_SIZE * effective_scale

	# Use floor() to snap to the correct tile and then offset by half a tile to center.
	var snapped_pos = Vector2(
		floor(local_pos.x / tile_size) * tile_size,
		floor(local_pos.y / tile_size) * tile_size
	)
	bomb.position = snapped_pos + Vector2(tile_size * 0.5, tile_size * 0.5)
	parent.add_child(bomb)

	bombs_placed += 1 
	bomb.tree_exiting.connect(Callable(self, "on_bomb_exploded").bind(bomb))

	if timebomb:
		timebomb_bombs.append(bomb)


# Called when a bomb leaves the scene.
func on_bomb_exploded(bomb):
	bombs_placed -= 1
	# Remove from our timebomb list if it’s there.
	if bomb in timebomb_bombs:
		timebomb_bombs.erase(bomb)

# Called by the player when the drop_bomb input is released.
func trigger_all_timebombs():
	for bomb in timebomb_bombs:
		bomb.trigger_timebomb()
	# Clear the list after triggering.
	timebomb_bombs.clear()
