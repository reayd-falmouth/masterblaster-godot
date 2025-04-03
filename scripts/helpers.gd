extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Helper function to check if space is free in a small circle.
#func is_space_free_in_circle(position: Vector2, radius: float) -> bool:
	#var space_state = get_world_2d().direct_space_state
	#var query = PhysicsShapeQueryParameters2D.new()
	#var circle_shape = CircleShape2D.new()
	#circle_shape.radius = radius
	#query.shape = circle_shape
	#query.transform = Transform2D(0, position)
	#query.collide_with_areas = false
	#query.collide_with_bodies = true
	#var result = space_state.intersect_shape(query)
	#return result.size() == 0
