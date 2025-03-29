extends Control

@onready var countdown_label = $CenterContainer/Label
var count = 3

func _ready():
	countdown_label.text = str(count)
	start_countdown()

func start_countdown() -> void:
	print(count)
	if count > 0:
		countdown_label.text = str(count)
		count -= 1
		# Wait one second then call start_countdown again
		await get_tree().create_timer(1.0).timeout
		start_countdown()
	else:
		# When count reaches 0, change to the game scene.
		get_tree().change_scene_to_file("res://scenes/game.tscn")
