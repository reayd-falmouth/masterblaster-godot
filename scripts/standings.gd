# Standings.gd
extends Control

@onready var players_vbox = $PlayersVBox

#func _ready():
	## 1) Check if any player has already won
	#for score in Globals.player_scores:
		#if score >= Globals.wins_needed:
			## Skip directly to "overs" scene
			#get_tree().change_scene("res://Overs.tscn")
			#return
	#
	## 2) Otherwise, display the scoreboard
	#display_scoreboard()

func display_scoreboard():
	# For each player, create a row that shows the player's icon
	# plus repeated trophy icons.
	
	for i in range(Globals.player_scores.size()):
		var score = Globals.player_scores[i]
		
		# Create an HBoxContainer for the row
		var player_row = HBoxContainer.new()
		players_vbox.add_child(player_row)
		
		# (A) Player icon
		var player_icon = TextureRect.new()
		# You might have a reference to a sprite or texture array
		# e.g., from a Resource or your Globals
		# Example: player_icon.texture = preload("res://PlayerIcons/player%i.png" % i)
		#player_icon.texture = preload("res://PlayerIcons/player_idle_down_%d.png" % i)
		#player_row.add_child(player_icon)
		#
		## (B) Trophies for this player's score
		#for t in range(score):
			#var trophy = TextureRect.new()
			#trophy.texture = preload("res://Icons/trophy.png")
			#player_row.add_child(trophy)

func _input(event):
	# Optionally, let the user press a key/button to proceed
	if event.is_action_pressed("ui_accept"):
		# Next match scene or whatever your flow is
		get_tree().change_scene("res://NextMatch.tscn")
