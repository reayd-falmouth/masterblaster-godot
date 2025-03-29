@tool
extends EditorScript

const SAVE_DIR := "res://resources/items/"

const ITEM_DATA = [
	{ "enabled": true, "key": "bomb", "name": "BOMB", "cost": 1, "value": 1, "weight": 20, "shop_item": true, "scene_path": "res://scenes/items/bomb.tscn" },
	{ "enabled": true, "key": "power", "name": "POWER", "cost": 1, "value": 1, "weight": 20, "shop_item": true, "scene_path": "res://scenes/items/power.tscn" },
	#{ "enabled": false, "key": "superman", "name": "SUPERMAN", "cost": 2, "weight": 3, "shop_item": true, "scene_path": "res://scenes/items/superman.tscn" },
	#{ "enabled": true, "key": "protection", "name": "PROTECTION", "cost": 3, "weight": 3, "shop_item": true, "scene_path": "res://scenes/items/protection.tscn" },
	#{ "enabled": true, "key": "ghost", "name": "GHOST", "cost": 3, "weight": 2, "shop_item": true, "duration": 15.0, "scene_path": "res://scenes/items/ghost.tscn" },
	{ "enabled": true, "key": "speed", "name": "SPEED", "cost": 4, "weight": 20, "value": 10, "shop_item": true, "scene_path": "res://scenes/items/speed.tscn" },
	{ "enabled": true, "key": "death", "name": "DEATH", "cost": 0, "weight": 20, "shop_item": false, "scene_path": "res://scenes/items/death.tscn" },
	#{ "enabled": true, "key": "random", "name": "RANDOM", "cost": 0, "weight": 5, "shop_item": false, "scene_path": "res://scenes/items/random.tscn" },
	{ "enabled": true, "key": "timebomb", "name": "TIMEBOMB", "cost": 2, "weight": 50, "shop_item": true, "scene_path": "res://scenes/items/timebomb.tscn" },
	{ "enabled": true, "key": "stop", "name": "STOP", "cost": 0, "weight": 10, "shop_item": false, "duration": 10.0, "scene_path": "res://scenes/items/stop.tscn" },
	{ "enabled": true, "key": "coin", "name": "COIN", "cost": 1, "weight": 20, "value": 1, "shop_item": false, "scene_path": "res://scenes/items/coin.tscn" },
	#{ "enabled": true, "key": "controller", "name": "CONTROLLER", "cost": 4, "weight": 70, "shop_item": true, "scene_path": "res://scenes/items/controller.tscn" },
	{ "enabled": true, "key": "none", "name": "NONE", "cost": 0, "weight": 50, "shop_item": false, "scene_path": "" }
]

func _run():
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(SAVE_DIR)):
		DirAccess.make_dir_absolute(ProjectSettings.globalize_path(SAVE_DIR))

	for item in ITEM_DATA:
		if not item.enabled:
			continue

		var def = ItemDefinition.new()
		def.key = item.key
		def.display_name = item.name
		def.cost = item.cost
		def.weight = item.weight
		def.shop_item = item.shop_item

		if item.has("duration"):
			def.duration = item.duration

		if item.has("value"):
			def.value = item.value
			
		if item.scene_path != "":
			def.scene_path = item.scene_path

		var save_path = SAVE_DIR + item.key + ".tres"
		var result = ResourceSaver.save(def, save_path)
		if result != OK:
			push_error("Failed to save %s" % save_path)
		else:
			print("✅ Created:", save_path)

	print("🎉 All enabled item definitions created!")
