extends Area2D

# All properties are defined in one place.
@export var item_definition: ItemDefinition
@export var pickup_sound: AudioStream
		
func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		apply_to_player(area)
		play_pickup_sound()
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		apply_to_player(body)
		play_pickup_sound()
		queue_free()

func play_pickup_sound() -> void:
	if pickup_sound:
		var sound = AudioStreamPlayer2D.new()
		sound.stream = pickup_sound
		sound.global_position = global_position
		get_tree().current_scene.add_child(sound)
		sound.play()

func apply_to_player(player: Node) -> void:
	print("Applying %s to player" % item_definition.key)
	match item_definition.key:
		"speed":
			if "speed" in player:
				player.speed += item_definition.value
				print("%s speed increased to %s" % [player.name, player.speed])
		"bomb":
			if "bombs" in player:
				player.bombs += item_definition.value
				print("%s bomb count increased to %s" % [player.name, player.bombs])
		"power":
			if "power" in player:
				player.power += item_definition.value
				print("%s power increased to %s" % [player.name, player.power])
		"death":
			if player.has_method("die"):
				player.die()
				print("%s killed by death-skull" % player.name)
		"coin":
			if "money" in player:
				player.money += item_definition.value
				print("%s money increased to %s" % [player.name, player.money])
		"stop":
			if player.has_method("stop"):
				player.stop(item_definition.duration)
				print("%s stopped for %s" % [player.name, item_definition.duration])
		"timebomb":
			if "timebomb" in player:
				player.timebomb = true
				print("%s has timebomb activated" % player.name)
		_:
			push_warning("No logic defined for item key: %s" % item_definition.key)
