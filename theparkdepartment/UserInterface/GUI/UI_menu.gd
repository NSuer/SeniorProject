extends Control

signal start_object_placement(structure_type)

var animalStats = [{
	"name": "Deer",
	"hunger": 80,
	"thirst": 80,
	"max-hunger": 80,
	"max-thirst": 80
},{
	"name": "Wolf",
	"hunger": 100,
	"thirst": 100,
	"max-hunger": 100,
	"max-thirst": 100
},{
	"name": "Bird",
	"hunger": 50,
	"thirst": 50,
	"max-hunger": 50,
	"max-thirst": 50
},{
	"name": "Fox",
	"hunger": 75,
	"thirst": 75,
	"max-hunger": 75,
	"max-thirst": 75
},{
	"name": "Squirrel",
	"hunger": 50,
	"thirst": 50,
	"max-hunger": 50,
	"max-thirst": 50
}]

# ANIMAL STATS
var tracking = false
var index

# CLOCK
var meridiem
var clock = 288 # 4:48 AM
var day = 1;
var mult = 1;
var check = 0;

var DeerCount
var WolfCount
var BirdCount
var Plant1Count
var Plant2Count
var Plant3Count

# Object Prices
var fence_cost = 25 
var log_cabin_cost = 125
var watchtower_cost = 150
var tree_cost = 10
var bathroom_cost = 50

#Object Determination
var selected_object = ""

func _process(delta: float) -> void:
	#for i in animalStats:
		#i.hunger = i.hunger - 0.025
		#i.thirst = i.thirst - 0.025
	
	#if (tracking == true && index != null):
		#$HungerBar.value = animalStats[index].hunger
		#$ThirstBar.value = animalStats[index].thirst
	
	if (check == 20):
		clock = clock + mult;
		check = 0
	check = check + 1
	
	if (clock == 1440):
		clock = 0
		day += 1
		$DayCount.text = "Day " + str(day)
	elif (clock >= 1440):
		clock = 0
		print("Color Error")
	
	var hour = floor(clock / 60)
	var minutes = clock - (hour * 60)
	if (minutes < 10):
		minutes = "0" + str(minutes)
		
	if (clock > 720):
		meridiem = "pm";
	else:
		meridiem = "am";
	
	$Clock.text = str(hour) + ":" + str(minutes) + meridiem

func _ready() -> void:
	$BuildMenu/FencePrice.add_theme_color_override("bg_color", Color.WEB_GREEN)
	#var menu = get_node("MenuButton")
	#menu.get_popup().add_item("Deer")
	#menu.get_popup().add_item("Wolf")
	#menu.get_popup().add_item("Bird")
	#menu.get_popup().add_item("Fox")
	#menu.get_popup().add_item("Squirrel")
	#menu.get_popup().id_pressed.connect(_on_item_menu_pressed)

#func _on_item_menu_pressed(id: int):
	#$HungerBar.visible = true;
	#$ThirstBar.visible = true;
	#
	#if (id == 0): # Deer
		#$HungerBar.value = animalStats[0].hunger
		#$ThirstBar.value = animalStats[0].thirst
	#elif (id == 1): # Wolf
		#$HungerBar.value = animalStats[1].hunger
		#$ThirstBar.value = animalStats[1].thirst
	#elif (id == 2): # Bird
		#$HungerBar.value = animalStats[2].hunger
		#$ThirstBar.value = animalStats[2].thirst
	#elif (id == 3): # Fox
		#$HungerBar.value = animalStats[3].hunger
		#$ThirstBar.value = animalStats[3].thirst
	#elif (id == 4): # Squirrel
		#$HungerBar.value = animalStats[4].hunger
		#$ThirstBar.value = animalStats[4].thirst
	#index = id
	#tracking = true;


func _on_place_fence_button_pressed():
	selected_object = "Fence"
	emit_signal("start_object_placement", selected_object)
	building_check()


func _on_place_cabin_button_pressed():
	selected_object = "Log Cabin"
	emit_signal("start_object_placement", selected_object)
	building_check()


func _on_place_watchtower_button_pressed():
	selected_object = "Watchtower"
	emit_signal("start_object_placement", selected_object)
	building_check()


func _on_place_trees_button_pressed():
	selected_object = "Trees"
	emit_signal("start_object_placement", selected_object)
	building_check()


func _on_place_bathroom_button_pressed():
	selected_object = "Bathroom"
	emit_signal("start_object_placement", selected_object)
	building_check()


func building_check() -> void:
	if (selected_object == "Fence"):
		$BuildConfirmation/BuildCost.text = "Cost: $25"
	elif (selected_object == "Log Cabin"):
		$BuildConfirmation/BuildCost.text = "Cost: $125"
	elif (selected_object == "Watchtower"):
		$BuildConfirmation/BuildCost.text = "Cost: $150"
	elif (selected_object == "Trees"):
		$BuildConfirmation/BuildCost.text = "Cost: $10"
	elif (selected_object == "Bathroom"):
		$BuildConfirmation/BuildCost.text = "Cost: $50"
	
	$BuildConfirmation.visible = true


func _on_fast_forward_button_pressed() -> void:
	mult = 2;
func _on_play_button_pressed() -> void:
	mult = 1;
func _on_pause_button_pressed() -> void:
	mult = 0;


func _on_animal_status_button_pressed() -> void:
	if ($BuildMenu.visible == true):
		$BuildMenu.visible = false
	if ($Panel.visible == true and $Panel/ListHeader.text == "Animal Count"):
		$Panel.visible = false
	elif ($Panel/ListHeader.text == "Plant Count" and $Panel.visible == true):
		$Panel.visible = true
	else:
		$Panel.visible = true
		
	$Panel/ListHeader.text = "Animal Count"
	$Panel/ListItem1.text = "White Tailed Deer: " + str(DeerCount)
	$Panel/ListItem2.text = "Wolf: " + str(WolfCount)
	$Panel/ListItem3.text = "Bird: " + str(BirdCount)


func _on_plant_status_button_pressed() -> void:
	if ($BuildMenu.visible == true):
		$BuildMenu.visible = false
	if ($Panel.visible == true and $Panel/ListHeader.text == "Plant Count"):
		$Panel.visible = false
	elif ($Panel/ListHeader.text == "Animal Count" and $Panel.visible == true):
		$Panel.visible = true
	else:
		$Panel.visible = true
	
	$Panel/ListHeader.text = "Plant Count"
	$Panel/ListItem1.text = "Plant1: " + str(Plant1Count)
	$Panel/ListItem2.text = "Plant2: " + str(Plant2Count)
	$Panel/ListItem3.text = "Plant3: " + str(Plant3Count)


func _on_exit_menu_pressed() -> void:
	$Panel.visible = false


func _on_building_button_pressed() -> void:
	if ($Panel.visible == true):
		$Panel.visible = false
	
	$BuildMenu.visible = true


func _on_exit_menu_2_pressed() -> void:
	$BuildMenu.visible = false


func _on_cofirm_build_pressed() -> void:
	pass # Place the Selected Object

func _on_cancel_build_pressed() -> void:
	$BuildConfirmation.visible = false
	selected_object = ""
