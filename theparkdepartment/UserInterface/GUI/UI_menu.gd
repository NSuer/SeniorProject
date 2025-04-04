extends Control

signal start_object_placement(structure_type)
signal confirm_object_placement()
signal cancel_object_placement()

# ANIMAL STATS
var tracking = false
var index

# CLOCK
var meridiem
var clock = 288 # 4:48 AM
var day = 1;
var mult = 1;
var check = 0;

# ANIMAL COUNTS
var DeerCount
var RabbitCount
var EasternWolfCount
var CoyoteCount
var AmericanGoldfinchCount
var CoopersHawkCount
var PlantCount

# RNG
var rng = RandomNumberGenerator.new()

# Object Prices
var building_prices = {
	"Fence": 25,
	"Log Cabin": 125,
	"Watchtower": 150,
	"Trees": 10,
	"Bathroom": 50,
}

#Object Determination
var selected_object = ""

var animal_facts = {
	"1": {
		"name": "White-tailed Deer",
		"image": "res://UserInterface/GUI/Animal Images/deer.png",
		"facts" : {
			"1": "Baby white-tailed deer, called fawns, are born with spots that help them camouflage with their surroundings, making it difficult for predators to spot them.",
			"2": "White-tailed deer have a four-chambered stomach, which allows them to digest a wide variety of vegetation, including thorny plants and even some poisonous mushrooms.",
			"3": "White-tailed deer communicate through a variety of sounds, including snorts, bleats, and grunts, and they also use their tails to signal danger by 'flagging.'"
		}
	},
	"2": {
		"name": "Eastern Wolf",
		"image": "res://UserInterface/GUI/Animal Images/wolf.png",
		"facts" : {
			"1": "They are a hybrid species, with genetic evidence suggesting they are about 58% gray wolf and 42% coyote.",
			"2": "They use a variety of vocalizations, body language, and scent marking to communicate within their packs.",
			"3": "They are found in deciduous and mixed forest landscapes, often near water sources and in areas with abundant prey like white-tailed deer and moose."
		}
	},
	"3": {
		"name": "Coyote",
		"image": "res://UserInterface/GUI/Animal Images/coyote.png",
		"facts" : {
			"1": "Coyotes are not strictly nocturnal; they are crepuscular, meaning they are most active during dawn and dusk, but can be active at any time of the day or night.",
			"2": "Coyotes use a wide array of vocalizations, including howls, yips, barks, and growls, to communicate with each other and warn of danger.",
			"3": "Coyotes can run up to 40 miles per hour, making them one of the fastest land mammals in North America."
		}
	},
	"4": {
		"name": "Eastern Cottontail Rabbit",
		"image": "res://UserInterface/GUI/Animal Images/rabbit.png",
		"facts" : {
			"1": "They are herbivores and eat a variety of plants, including grasses, clovers, alfalfa, plantain, and dandelions.",
			"2": "They prefer areas with dense shrubs for protection and open areas with green grasses and herbs for foraging.",
			"3": "They use speed and caution to avoid predators, and can reach speeds of up to 18 mph when running."
		}
	},
	"5": {
		"name": "Goldfinch",
		"image": "res://UserInterface/GUI/Animal Images/goldfinch.png",
		"facts" : {
			"1": "Goldfinches are almost exclusively vegetarians, primarily feeding on seeds, especially those of the daisy family.",
			"2": "They are unique among finches in molting their feathers twice a year, once in late winter/early spring and again in late summer/early fall.",
			"3": "Paired-up goldfinches make virtually identical flight calls, which may help them distinguish members of their pair."
		}
	},
	"6": {
		"name": "Coopers Hawk",
		"image": "res://UserInterface/GUI/Animal Images/hawk.png",
		"facts" : {
			"1": "Cooper's hawks are stealthy hunters, often ambushing prey from perches or moving quietly through dense cover before launching a quick attack.",
			"2": "They have short, powerful wings and a long tail, which allows them to be highly maneuverable in dense forest habitats.",
			"3": "Female Cooper's Hawks are about 30% larger than their male counterparts."
		}
	},
	"7": {
		"name": "Black Vulture",
		"image": "res://UserInterface/GUI/Animal Images/BlackVulture.png",
		"facts" : {
			"1": "Black vultures usually feed together in large groups, and are so aggressive that other vulture species will stay away.",
			"2": "Both the male and female parents take turns incubating their eggs.",
			"3": "Black vulture mating pairs may remain together and reuse a successful nesting site for many years."
		}
	},
	"8": {
		"name": "Turkey Vulture",
		"image": "res://UserInterface/GUI/Animal Images/TurkeyVulture.png",
		"facts" : {
			"1": "Turkey vultures are primarily scavengers, playing a crucial role in the ecosystem by consuming carrion and preventing the spread of disease.",
			"2": "Their keen sense of smell is one of the most remarkable adaptations, enabling them to locate food from miles away.",
			"3": "They are known for their graceful soaring flight, using thermals to conserve energy and travel long distances."
		}
	}
}

func _process(delta: float) -> void:
	#for i in animalStats:
		#i.hunger = i.hunger - 0.025
		#i.thirst = i.thirst - 0.025
	
	#if (tracking == true && index != null):
		#$HungerBar.value = animalStats[index].hunger
		#$ThirstBar.value = animalStats[index].thirst
	$Panel2/Funds.text = "$" + str(OhioEcosystemData.funds)
	$Panel3/ReleaseCount.text = str(OhioEcosystemData.releasecount)
	
	if ($Panel/ListHeader.text == "Animal Count"):
		$Panel/ScrollContainer/VBoxContainer/ListItem1.text = "White Tailed Deer: " + str(OhioEcosystemData.animals_species_data["Deer"]["count"])
		$Panel/ScrollContainer/VBoxContainer/ListItem2.text = "Rabbit: " + str(OhioEcosystemData.animals_species_data["Rabbit"]["count"])
		$Panel/ScrollContainer/VBoxContainer/ListItem3.text = "Eastern Wolf: " + str(OhioEcosystemData.animals_species_data["EasternWolf"]["count"])
		$Panel/ScrollContainer/VBoxContainer/ListItem4.text = "Coyote: " +  str(OhioEcosystemData.animals_species_data["Coyote"]["count"])
		$Panel/ScrollContainer/VBoxContainer/ListItem5.text = "American Goldfinch: " + str(OhioEcosystemData.animals_species_data["AmericanGoldfinch"]["count"])
		$Panel/ScrollContainer/VBoxContainer/ListItem6.text = "Cooper's Hawk: " + str(OhioEcosystemData.animals_species_data["CoopersHawk"]["count"])
	elif ($Panel/ListHeader.text == "Plant Count"):
		$Panel/ScrollContainer/VBoxContainer/ListItem1.text = "Grass: " + str(OhioEcosystemData.plants_species_data["Grass"]["count"])
	
	if (check == 20):
		clock = clock + mult;
		check = 0
	check = check + 1
	
	if (clock == 1440):
		clock = 0
		day += 1
		OhioEcosystemData.releasecount += 1
		$DayCount/Label.text = "Day " + str(day)
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
	
	$Clock/Label.text = str(hour) + ":" + str(minutes) + meridiem

func _ready() -> void:
	$BuildMenu/BuildingOptions/VBoxContainer/HBoxContainer2/TreesButton/TreesPrice.add_theme_color_override("bg_color", Color.WEB_GREEN)
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
	if OhioEcosystemData.funds >= building_prices["Fence"]:
		selected_object = "Fence"
		emit_signal("start_object_placement", selected_object)


func _on_place_cabin_button_pressed():
	if OhioEcosystemData.funds >= building_prices["Log Cabin"]:
		selected_object = "Log Cabin"
		emit_signal("start_object_placement", selected_object)


func _on_place_watchtower_button_pressed():
	if OhioEcosystemData.funds >= building_prices["Watchtower"]:
		selected_object = "Watchtower"
		emit_signal("start_object_placement", selected_object)


func _on_place_trees_button_pressed():
	if OhioEcosystemData.funds >= building_prices["Trees"]:
		selected_object = "Trees"
		emit_signal("start_object_placement", selected_object)


func _on_place_bathroom_button_pressed():
	if OhioEcosystemData.funds >= building_prices["Bathroom"]:
		selected_object = "Bathroom"
		emit_signal("start_object_placement", selected_object)


func placement_requested(structure_type) -> void:
	$BuildConfirmation/Label.text = "Click the checkbox to confirm your build!"
	if (structure_type == "Fence"):
		$BuildConfirmation/BuildCost.text = "Cost: $25"
	elif (structure_type == "Log Cabin"):
		$BuildConfirmation/BuildCost.text = "Cost: $125"
	elif (structure_type == "Watchtower"):
		$BuildConfirmation/BuildCost.text = "Cost: $150"
	elif (structure_type == "Trees"):
		$BuildConfirmation/BuildCost.text = "Cost: $10"
	elif (structure_type == "Bathroom"):
		$BuildConfirmation/BuildCost.text = "Cost: $50"
	
	$BuildConfirmation.visible = true
	selected_object = structure_type


func _on_fast_forward_button_pressed() -> void:
	OhioEcosystemData.speedMult = 0.2
func _on_play_button_pressed() -> void:
	OhioEcosystemData.speedMult = 0.1
func _on_pause_button_pressed() -> void:
	OhioEcosystemData.speedMult = 0


func _on_animal_status_button_pressed() -> void:
	if ($BuildMenu.visible == true):
		$BuildMenu.visible = false
	if ($Panel.visible == true and $Panel/ListHeader.text == "Animal Count"):
		$Panel.visible = false
		return
	
	$Panel.size = Vector2(287, 269)
	$Panel.position.y = 806
	$Panel/ListHeader.text = "Animal Count"
	$Panel/ScrollContainer/VBoxContainer/ListItem1.visible = true
	$Panel/ScrollContainer/VBoxContainer/ListItem2.visible = true
	$Panel/ScrollContainer/VBoxContainer/ListItem3.visible = true
	$Panel/ScrollContainer/VBoxContainer/ListItem4.visible = true
	$Panel/ScrollContainer/VBoxContainer/ListItem5.visible = true
	$Panel/ScrollContainer/VBoxContainer/ListItem6.visible = true
	$Panel.visible = true


func _on_plant_status_button_pressed() -> void:
	if ($BuildMenu.visible == true):
		$BuildMenu.visible = false
	if ($Panel.visible == true and ($Panel/ListHeader.text == "Plant Count")):
		$Panel.visible = false
		return
	
	$Panel.size = Vector2(287, 104)
	$Panel.position.y = 971
	$Panel/ListHeader.text = "Plant Count"
	$Panel/ScrollContainer/VBoxContainer/ListItem1.visible = true
	$Panel/ScrollContainer/VBoxContainer/ListItem2.visible = false
	$Panel/ScrollContainer/VBoxContainer/ListItem3.visible = false
	$Panel/ScrollContainer/VBoxContainer/ListItem4.visible = false
	$Panel/ScrollContainer/VBoxContainer/ListItem5.visible = false
	$Panel/ScrollContainer/VBoxContainer/ListItem6.visible = false
	$Panel.visible = true


func _on_exit_menu_pressed() -> void:
	$Panel.visible = false


func _on_building_button_pressed() -> void:
	if ($Panel.visible == true):
		$Panel.visible = false
	if ($BuildMenu.visible == true and $BuildMenu/BuildMenuLabel.text == "Building"):
		$BuildMenu.visible = false
		return
	
	$BuildMenu/BuildMenuLabel.text = "Building"
	$BuildMenu/AnimalOptions.visible = false
	$BuildMenu/BuildingOptions.visible = true
	$BuildMenu.visible = true

func _on_releasing_button_pressed() -> void:
	if ($Panel.visible == true):
		$Panel.visible = false
	if ($BuildMenu.visible == true and $BuildMenu/BuildMenuLabel.text == "Release an animal"):
		$BuildMenu.visible = false
		return
	
	$BuildMenu/BuildMenuLabel.text = "Release an animal"
	$BuildMenu/BuildingOptions.visible = false
	$BuildMenu/AnimalOptions.visible = true
	$BuildMenu.visible = true

func _on_exit_menu_2_pressed() -> void:
	$BuildMenu.visible = false


func _on_confirm_build_pressed() -> void:
	if OhioEcosystemData.funds >= building_prices[selected_object]:
		OhioEcosystemData.funds -= building_prices[selected_object]
		emit_signal("confirm_object_placement")
		$BuildConfirmation.visible = false
		selected_object = ""

func _on_cancel_build_pressed() -> void:
	emit_signal("cancel_object_placement")
	$BuildConfirmation.visible = false
	selected_object = ""

func _on_bulldozer_button_pressed() -> void:
	selected_object = "" # not sure how to wait for the user to select an object
	
	$BuildConfirmation/Label.text = "Click the checkbox to delete the selected build!"
	if (selected_object == "Fence"):
		$BuildConfirmation/BuildCost.text = "Refund: $20"
	elif (selected_object== "Log Cabin"):
		$BuildConfirmation/BuildCost.text = "Refund: $100"
	elif (selected_object == "Watchtower"):
		$BuildConfirmation/BuildCost.text = "Cost: $120"
	elif (selected_object == "Trees"):
		$BuildConfirmation/BuildCost.text = "Cost: $10"
	elif (selected_object == "Bathroom"):
		$BuildConfirmation/BuildCost.text = "Cost: $40"



func _on_facts_button_pressed() -> void:
	$"Random Facts".visible = true
	var animal_selection = round(rng.randf_range(0.5, len(animal_facts)+0.49))
	var fact_selection = round(rng.randf_range(0.5, len(animal_facts[str(animal_selection)]["facts"])+0.49))
	
	var full_fact = animal_facts[str(animal_selection)]["facts"][str(fact_selection)]
	var fact = ""
	for i in range(len(full_fact)-1):
		if i <= 80:
			if (i % 16 == 0) and i != 0:
				if (full_fact[i] != " " and full_fact[i] != "," and full_fact[i] != ";"):
					if full_fact[i] == " ":
						print("SPACE")
					if (full_fact[i-1] == " "):
						fact += "\n" + full_fact[i]
						print(full_fact[i], " letter but previous letter space")
					else: 
						fact += "-\n" + full_fact[i]
						print(full_fact[i], " letter standard dash")
				else:
					if (full_fact[i] != " "):
						fact += "\n" + full_fact[i]
						print(full_fact[i], " comma or semi col")
					else:
						i+=1
						fact += "\n" + full_fact[i]
						print(full_fact[i], " space!!")
			else:
				fact += full_fact[i]
		else:
			if ((i-80)% 31 == 0) and i != 0:
				if (full_fact[i] != " " and full_fact[i] != "," and full_fact[i] != ";"):
					if full_fact[i] == " ":
						print("SPACE")
					if (full_fact[i-1] == " "):
						fact += "\n" + full_fact[i]
						print(full_fact[i], " letter but previous letter space")
					else: 
						fact += "-\n" + full_fact[i]
						print(full_fact[i], " letter standard dash")
				else:
					if (full_fact[i] != " "):
						fact += "\n" + full_fact[i]
						print(full_fact[i], " comma or semi col")
					else:
						i+=1
						fact += "\n" + full_fact[i]
						print(full_fact[i], " space!!")
			else:
				fact += full_fact[i]
	#
	$"Random Facts/Photo".texture = load(animal_facts[str(animal_selection)]["image"])
	$"Random Facts/Header".text = animal_facts[str(animal_selection)]["name"]
	$"Random Facts/Fact".text = fact


func _on_exit_menu_3_pressed() -> void:
	$"Random Facts".visible = false
