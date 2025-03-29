extends Node

var item_definitions: Array[ItemDefinition] = []

func _ready():
	load_all_item_definitions("res://resources/items")

func load_all_item_definitions(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("❌ Could not open directory: " + path)
		return

	item_definitions.clear()
	dir.list_dir_begin()

	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		if file_name.ends_with(".tres"):
			var full_path = path + "/" + file_name
			var res = load(full_path)
			if res != null and res is ItemDefinition:
				item_definitions.append(res)
				print("✅ Loaded:", res.key)
			else:
				print("⚠️ Skipped (not ItemDefinition):", full_path)

	dir.list_dir_end()
	print("🎯 Loaded %d item definitions." % item_definitions.size())

func get_random_item() -> Dictionary:
	var valid_items = item_definitions.filter(func(def): return def.enabled and def.weight > 0)

	var total_weight = 0
	for def in valid_items:
		total_weight += def.weight

	if total_weight == 0:
		return {}

	var roll = randf_range(0.0, total_weight)
	var cumulative = 0.0

	for def in valid_items:
		cumulative += def.weight
		if roll <= cumulative:
			return {
				"scene_path": def.scene_path,
				"definition": def
			}

	return {}
