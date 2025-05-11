extends Area2D
class_name Fireball

func _ready():
	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.connect("animation_finished", Callable(self, "_on_animatedSprite_animation_finished"))
	# Connect to collision signals to detect bodies that enter.
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_animatedSprite_animation_finished():
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body is TileMapLayer:
		return  # Ignore TileMapLayer collisions
	
	# Check for bomb collisions using collision layers:
	if body.collision_layer:
		if body.has_method("destroy"):
			body.destroy()
		elif body.has_method("explode"):
			body.explode()
		elif body.has_method("die"):
			body.die()
			
