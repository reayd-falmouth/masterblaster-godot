extends StaticBody2D
class_name BrickWall

func _ready():
	add_to_group("destructible")
	# Connect animation_finished once at ready
	$AnimatedSprite2D.connect("animation_finished", Callable(self, "_on_animated_sprite_2d_animation_finished"))

func destroy():
	$AnimatedSprite2D.play("destroy")

func _on_animated_sprite_2d_animation_finished() -> void:
	# Only drop an item after "destroy" animation finishes
	drop_item()
	queue_free()

func drop_item():
	var result = ItemDatabase.get_random_item()
	if result.is_empty():
		return

	var scene_path = result["scene_path"]
	var item_def = result["definition"]

	if scene_path:
		var scene_res = load(scene_path)  # Load the PackedScene from the path
		if scene_res:
			# Capture the parent's reference and the current global position
			var parent_node = get_parent()
			var spawn_position = global_position

			# Instantiate the item
			var item = scene_res.instantiate()
			# Convert the global position to parent's local space.
			item.position = parent_node.to_local(spawn_position)
			if item.has_method("set_item_definition"):
				item.set_item_definition(item_def)
			parent_node.add_child(item)
		else:
			push_error("Failed to load scene from path: " + scene_path)
