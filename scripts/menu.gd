extends Control

# We'll reference the global GameSettings directly.
# By default, after adding it to AutoLoad, you can just write `GameSettings`.

var menu_items = []
var current_index = 0

func _ready():
	# Build a list describing each menu row
	menu_items = [
		{
			"pointer_label": $CenterContainer/VBoxContainer/MenuContainer/WinsNeededItem/PointerLabel,
			"value_label":   $CenterContainer/VBoxContainer/MenuContainer/WinsNeededItem/MarginContainer/ValueLabel,
			"setting_name":  "wins_needed",
			"display_type":  "int"  # We'll increment/decrement
		},
		{
			"pointer_label": $CenterContainer/VBoxContainer/MenuContainer/PlayersItem/PointerLabel,
			"value_label":   $CenterContainer/VBoxContainer/MenuContainer/PlayersItem/MarginContainer/ValueLabel,
			"setting_name":  "players",
			"display_type":  "int"
		},
		{
			"pointer_label": $CenterContainer/VBoxContainer/MenuContainer/ShopItem/PointerLabel,
			"value_label":   $CenterContainer/VBoxContainer/MenuContainer/ShopItem/MarginContainer/ValueLabel,
			"setting_name":  "shop",
			"display_type":  "yesno"  # boolean displayed as YES/NO
		},
		{
			"pointer_label": $CenterContainer/VBoxContainer/MenuContainer/ShrinkingItem/PointerLabel,
			"value_label":   $CenterContainer/VBoxContainer/MenuContainer/ShrinkingItem/MarginContainer/ValueLabel,
			"setting_name":  "shrinking",
			"display_type":  "onoff"  # boolean displayed as ON/OFF
		},
		{
			"pointer_label": $CenterContainer/VBoxContainer/MenuContainer/FastIgnitionItem/PointerLabel,
			"value_label":   $CenterContainer/VBoxContainer/MenuContainer/FastIgnitionItem/MarginContainer/ValueLabel,
			"setting_name":  "fast_ignition",
			"display_type":  "onoff"
		},
		{
			"pointer_label": $CenterContainer/VBoxContainer/MenuContainer/StartMoneyItem/PointerLabel,
			"value_label":   $CenterContainer/VBoxContainer/MenuContainer/StartMoneyItem/MarginContainer/ValueLabel,
			"setting_name":  "start_money",
			"display_type":  "yesno"
		},
		{
			"pointer_label": $CenterContainer/VBoxContainer/MenuContainer/NormalLevelItem/PointerLabel,
			"value_label":   $CenterContainer/VBoxContainer/MenuContainer/NormalLevelItem/MarginContainer/ValueLabel,
			"setting_name":  "normal_level",
			"display_type":  "onoff"
		},
		{
			"pointer_label": $CenterContainer/VBoxContainer/MenuContainer/GamblingItem/PointerLabel,
			"value_label":   $CenterContainer/VBoxContainer/MenuContainer/GamblingItem/MarginContainer/ValueLabel,
			"setting_name":  "gambling",
			"display_type":  "yesno"
		},
	]
	
	# Highlight the first item and refresh all display labels
	highlight_item(current_index)
	update_all_labels()

func _unhandled_input(event):
	if event.is_action_pressed("ui_up"):
		current_index -= 1
		if current_index < 0:
			current_index = menu_items.size() - 1
		highlight_item(current_index)
		update_all_labels()
	
	elif event.is_action_pressed("ui_down"):
		current_index += 1
		if current_index >= menu_items.size():
			current_index = 0
		highlight_item(current_index)
		update_all_labels()
	
	elif event.is_action_pressed("ui_left"):
		# Decrement or toggle the currently selected setting
		change_setting(-1)
		update_all_labels()
	
	elif event.is_action_pressed("ui_right"):
		# Increment or toggle
		change_setting(1)
		update_all_labels()
	
	elif event.is_action_pressed("ui_accept"):
		# "Enter" or "Space" pressed on the current item
		# Could do something else, like open a sub-menu, confirm, etc.
		_go_to_next_scene()
		
func _go_to_next_scene():
	# Change the scene to your next screen. Update the path accordingly.
	get_tree().change_scene_to_file("res://scenes/countdown.tscn")
	
func highlight_item(index):
	# Clear pointer ">" from all items first
	for i in range(menu_items.size()):
		menu_items[i].pointer_label.text = " "
	
	# Set ">" on the selected item
	menu_items[index].pointer_label.text = ">"

func update_all_labels():
	# Loop through each item, read from GameSettings, and set label text
	for item in menu_items:
		var setting_value = GameSettings[item.setting_name]
		item.value_label.text = get_display_value(setting_value, item.display_type)

func get_display_value(value, display_type: String) -> String:
	match display_type:
		"int":
			return str(value)  # just show the integer
		"yesno":
			return "YES" if value else "NO"
		"onoff":
			return "ON" if value else "OFF"
		_:
			# fallback
			return str(value)

func change_setting(direction: int):
	var item = menu_items[current_index]
	var setting_name = item.setting_name
	var display_type = item.display_type
	
	var current_val = GameSettings[setting_name]
	
	match display_type:
		"int":
			# Increase or decrease by 1
			current_val += direction
			# Use different ranges based on the setting name
			if setting_name == "players":
				current_val = clamp(current_val, 2, 5)
			elif setting_name == "wins_needed":
				current_val = clamp(current_val, 1, 9)
			else:
				current_val = clamp(current_val, 1, 99)
			GameSettings[setting_name] = current_val
		
		"yesno", "onoff":
			# Toggle the boolean
			GameSettings[setting_name] = not current_val

	# If you have a special case for start_money_amount, 
	# you could handle it here or create a separate menu item for it.
