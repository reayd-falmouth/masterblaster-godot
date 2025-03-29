extends Node
class_name FireballSpawner

var FIREBALL = preload("res://scenes/fireball.tscn")

func spawn_fireball(target_position: Vector2, delay: float) -> void:
	var timer = Timer.new()
	timer.wait_time = delay
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(func() -> void:
		var fireball_instance = FIREBALL.instantiate()
		fireball_instance.position = target_position
		get_tree().root.add_child(fireball_instance)
		timer.queue_free()
	)
	timer.start()
