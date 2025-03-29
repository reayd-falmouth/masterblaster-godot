extends Resource
class_name ItemDefinition

@export var key: String
@export var display_name: String
@export var weight: int = 1
@export var cost: int = 0
@export var duration: float = 0.0
@export var shop_item: bool = true
@export var enabled: bool = true
@export var value: int = 0
@export var scene_path: String  # Store the path instead of a PackedScene
