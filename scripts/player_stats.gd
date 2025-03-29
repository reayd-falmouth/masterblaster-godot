# player_stats.gd
extends Node

# This array holds a dictionary for each player's stats.
var players_data = []

# Resets all player data.
func reset():
	players_data.clear()

# Adds a new player with default stats.
# 'player_id' can be any identifier (name, index, etc.)
func add_player(player_id):
	var new_player = {
		"player_id": player_id,
		"wins": 0,
		"money": 0,
		"items": []
	}
	players_data.append(new_player)

# (Optional) Retrieve stats for a specific player index.
func get_player_stats(index):
	if index >= 0 and index < players_data.size():
		return players_data[index]
	return null

# (Optional) Increment the win count for a specific player.
func add_win(player_index):
	if player_index >= 0 and player_index < players_data.size():
		players_data[player_index]["wins"] += 1

# (Optional) Add money to a specific player's stats.
func add_money(player_index, amount):
	if player_index >= 0 and player_index < players_data.size():
		players_data[player_index]["money"] += amount
