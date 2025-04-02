extends Control

@onready var countdown_label = $CenterContainer/Label
var count: int = 3
var scene: String = "res://scenes/game.tscn"
	
func _ready():
	Globals.scale_bitmap_label_font(countdown_label)
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
		Globals.go_to_next_scene(scene)

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		Globals.scale_bitmap_label_font(countdown_label)
		
