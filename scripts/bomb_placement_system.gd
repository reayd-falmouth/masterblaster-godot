extends Node

class_name BombPlacementSystem 

const BOMB_SCENE = preload("res://Scenes/bomb.tscn")
const TILE_SIZE = 16

var player: Player = null
var bombs_placed = 0
var timebomb_bombs: Array = []   # To track remote (timebomb) bombs

func _ready() -> void:
	player = get_parent()

func place_bomb(timebomb: bool):
	if bombs_placed == player.bombs:
		return
	
	var bomb = BOMB_SCENE.instantiate()
	bomb.is_timebomb = timebomb           # Pass the timebomb flag to the bomb.
	bomb.explosion_size = player.power
	var player_position = player.position
	var bomb_position = Vector2(round(player_position.x / TILE_SIZE) * TILE_SIZE, 
								round(player_position.y / TILE_SIZE) * TILE_SIZE)
	bomb.position = bomb_position
	get_tree().root.add_child(bomb)
	bombs_placed += 1 
	# Connect the bomb’s tree_exiting signal and pass the bomb reference.
	bomb.tree_exiting.connect(Callable(self, "on_bomb_exploded").bind(bomb))
	
	# If this bomb is a timebomb, add it to the tracking list.
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
