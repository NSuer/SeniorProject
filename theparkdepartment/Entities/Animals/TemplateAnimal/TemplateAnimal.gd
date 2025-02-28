extends CharacterBody3D


# Animal variables; export the ones that we want to tweak in the editor
@export var species: String
@export var self_scene_path: String

@onready var eye_sight_area = $EyeSightArea
@onready var eye_sight_collision = $EyeSightArea/EyeSightCollision
@onready var mesh_instance = $MeshInstance3D

var animal_name: String
var age: int
var speed: float
var default_speed: float
var max_stamina: int
var stamina: int
var speed_modifier = 1
var gender: String
var animal_position: Vector2
var max_hunger: int
var hunger: int
var diet_type: String
var nutrition: int
var prey_organisms: Array
var max_age: int
var max_social: int
var social: int
var social_group_size: int
var eye_sight: int
var movement_chance: float
var reproduction_cooldown: int
var reproduction_timer: int
var desired_position = Vector3()
var animation_action: String = "idle"
var default_litter_size: int
var litter_size: int

var adjusted_eye_sight: float
var adjusted_eating_distance: float
var reproduction_range: float
var social_range: float

var half_tile = OhioEcosystemData.grid_scale * 0.5
var grid_bounds_min = -0.5 * OhioEcosystemData.grid_scale
var grid_bounds_max = (OhioEcosystemData.grid_scale) * (OhioEcosystemData.grid_size - 0.5)

var debug_telepathy_target = "deer_7"


func _ready():
	# Make sure species is set on this animal! (from the editor)
	assert(not species == null)
	
	# Fetch settings for this particular animal
	default_speed = OhioEcosystemData.animals_species_data[species]["speed"] * speed_modifier
	max_stamina = OhioEcosystemData.animals_species_data[species]["max_stamina"]
	max_hunger = OhioEcosystemData.animals_species_data[species]["max_hunger"]
	reproduction_cooldown = OhioEcosystemData.animals_species_data[species]["reproduction_cooldown"]
	max_age = OhioEcosystemData.animals_species_data[species]["max_age"]
	eye_sight = OhioEcosystemData.animals_species_data[species]["eye_sight"]
	movement_chance = OhioEcosystemData.animals_species_data[species]["movement_chance"]
	nutrition = OhioEcosystemData.animals_species_data[species]["nutrition"]
	diet_type = OhioEcosystemData.animals_species_data[species]["diet_type"]
	prey_organisms = OhioEcosystemData.animals_species_data[species]["prey_organisms"]
	max_social = OhioEcosystemData.animals_species_data[species]["max_social"]
	social_group_size = OhioEcosystemData.animals_species_data[species]["social_group_size"]
	default_litter_size = OhioEcosystemData.animals_species_data[species]["litter_size"]
	
	# Set initial conditions (slightly random)
	hunger = get_random_portion(max_hunger, 0.5, 1)
	reproduction_timer = get_random_portion(reproduction_cooldown, 0, 1) 
	age = get_random_portion(max_age, 0, 0.25)
	speed = get_random_portion(default_speed, 0.8, 1.2)
	social = get_random_portion(max_social, 0, 1)
	stamina = get_random_portion(max_stamina, 0, 1)
	litter_size = get_random_portion(default_litter_size, 0.5, 1.2)
	
	# Randomly assign gender
	gender = "Male" if randi() % 2 == 0 else "Female"
	
	adjusted_eye_sight = eye_sight * OhioEcosystemData.grid_scale * 0.25
	eye_sight_collision.shape = CylinderShape3D.new()
	eye_sight_collision.shape.height = 10
	eye_sight_collision.shape.radius = adjusted_eye_sight
	
	var eating_distance = 2.0
	adjusted_eating_distance = eating_distance * OhioEcosystemData.grid_scale * 0.25
	reproduction_range = adjusted_eating_distance
	social_range = adjusted_eye_sight / 4
	
	if animal_name == debug_telepathy_target:
		print("DEBUG: Telepathy target found!")
		$MeshInstance3D.mesh = CapsuleMesh.new()
		$MeshInstance3D.mesh.material = StandardMaterial3D.new()
		$MeshInstance3D.mesh.material.albedo_color = Color(0.96, 1, 0)


func _physics_process(delta):
	# Determine what direction the animal wants to move in
	var direction = (desired_position - position).normalized()
	
	# Move in the x and z directions as needed (y is height, so ignore it for now)
	if direction and position.distance_to(desired_position) > 1:
		animation_action = "walking"
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		# Set y rotation based on movement direction
		rotation.y = atan2(-direction.x, -direction.z)
	else:
		animation_action = "idle"
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	# Apply the new velocity
	move_and_slide()


func update():
	# Chance to move
	if randf() < movement_chance:
		decide_movement_new()
	
	# Update needs
	age += 1
	reproduction_timer -= 1
	hunger -= 1
	social -= 1
	
	# Eat if possible/needed
	if hunger < max_hunger:
		# Consider all plants and animals. If they are prey and it range, eat them
		var has_eaten = false
		if diet_type == "Herbivore" or diet_type == "Omnivore":
			var all_plants = get_tree().get_nodes_in_group("plants")
			all_plants.shuffle()
			for food_consideration in all_plants:
				# Only consider eating known prey_organisms
				if food_consideration.species in prey_organisms:
					# If the food is in range, eat it!
					if position.distance_to(food_consideration.position) <= adjusted_eating_distance:
						hunger = min(hunger + OhioEcosystemData.plants_species_data[food_consideration.species]["nutrition"], max_hunger)
						food_consideration.consumed()
						has_eaten = true
						print(animal_name, " ate a ", food_consideration.species, " at ", position)
						animation_action = "eating"
						break
		
		if (diet_type == "Carnivore" or diet_type == "Omnivore") and not has_eaten:
			var all_animals = get_tree().get_nodes_in_group("animals")
			all_animals.shuffle()
			for food_consideration in all_animals:
				# Only consider eating known prey_organisms
				if food_consideration.species in prey_organisms:
					# If the food is in range, eat it!
					if position.distance_to(food_consideration.position) <= adjusted_eating_distance:
						hunger = min(hunger + OhioEcosystemData.animals_species_data[food_consideration.species]["nutrition"], max_hunger)
						food_consideration.consumed()
						has_eaten = true
						print(animal_name, " ate a ", food_consideration.species, " at ", position)
						animation_action = "eating"
						break

	# For every entity of same species in range, increase social
	var all_entities = get_tree().get_nodes_in_group("animals")
	for entity in all_entities:
		if entity.species == species and position.distance_to(entity.position) <= social_range:
			social += 1
		# If this animal meets or exceeds it's social max, we can stop searching
		if social >= max_social:
			social = max_social
			break
	
	# If the animal needs removed, remove it!
	if is_starved():
		print(animal_name, " died of starvation at ", position)
		consumed()
	if is_old():
		print(animal_name, " died of old age at ", position)
		consumed()
		
	# Reproduce if conditions are right
	elif gender == "Female" and reproduction_timer <= 0:
		var all_animals = get_tree().get_nodes_in_group("animals")
		all_animals.shuffle()
		for animal in all_animals:
			if animal.species == species and position.distance_to(animal.position) <= reproduction_range and animal.gender != gender:
				reproduction_timer = reproduction_cooldown
				reproduce()
				print(animal_name, " reproduced with ", animal.animal_name, " at ", position)
				break


func reproduce():
	# Get the parent scene so we can add the new instance to it
	var parent = get_parent()
	assert(not parent == null)
	
	# Check that this species hasn't hit its limit
	var population_limit = OhioEcosystemData.animals_species_data[species]["population_limit"]
	if OhioEcosystemData.animals_species_data[species]["count"] >= population_limit:
		return
	
	# Have as many offspring as the litter size
	for i in range(litter_size):
		# Create a new instance of the current scene
		var new_animal = load(self_scene_path).instantiate()
		new_animal.position = position + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
		new_animal.animal_name = species.to_lower() + "_" + str(OhioEcosystemData.animals_species_data[species]["count"])
		new_animal.set_random_destination()
		
		# Add the new instance to the scene
		parent.add_child(new_animal)

		# Some of this might be redundant, but there was a bug where the new animal was getting the age of the parent
		# Setting these to max values so that babies are born with a good chance of survival
		new_animal.age = 0
		new_animal.reproduction_timer = get_random_portion(reproduction_cooldown, 0.2, 1)
		new_animal.hunger = max_hunger
		new_animal.speed = get_random_portion(default_speed, 0.8, 1.2)
		new_animal.social = get_random_portion(max_social, 0, 1)
		new_animal.stamina = get_random_portion(max_stamina, 0, 1)
		new_animal.litter_size = get_random_portion(default_litter_size, 0.5, 1.2)

		print("New " + species + " has been born: " + animal_name)
		OhioEcosystemData.animals_species_data[species]["count"] += 1



func decide_movement_new():
	# Set a value to help animals decide when to seek food / friends
	var hunger_threshold = 0.4
	var social_threshold = 0.3
	
	# Find current percentage of all needs
	var is_hungry = (float(hunger) / float(max_hunger)) < hunger_threshold
	var is_lonely = (float(social) / float(max_social)) < social_threshold
	
	var nearby_entities = eye_sight_area.get_overlapping_areas()
	# Shuffle the entities to avoid bias in decision making
	nearby_entities.shuffle()
	
	# Organize nearby entities into predators, friends, or prey
	var nearby_prey: Array
	var nearby_predators: Array
	var nearby_friends: Array
	for entity_area3d in nearby_entities:
		var entity = entity_area3d.get_parent()
		if entity.species in prey_organisms:
			nearby_prey.append(entity)
		elif "prey_organisms" in entity and species in entity.prey_organisms:
			nearby_predators.append(entity)
		elif entity.species == species:
			nearby_friends.append(entity)
	
	## PREDATOR AWARENESS
	# Scan for nearby predators. If any are dangerously close, flee away
	var threat_direction = Vector3()
	for predator in nearby_predators:
		if position.distance_to(predator.position) <= (0.5 * adjusted_eye_sight):
			# Add the vectors, so that an animal can flee from multiple predators at once
			threat_direction += (position - predator.position).normalized()
	# If there are predators nearby, flee in the opposite direction
	if threat_direction.length() > 0:
		if stamina > 0:
			stamina -= 1
			var flee_direction = threat_direction.normalized()
			var flee_target_position = position + (flee_direction * adjusted_eye_sight)
			telepathy_print("Predators nearby, running away!")
			set_desired_position(clamp_position(flee_target_position))
			# No other locations should be considered when predators are nearby
			return
		else: 
			# No stamina to flee, so just stay put
			# This is to avoid the constant chasing of predators, which would be unrealistic
			# this makes it so one animal eventually gets caught
			telepathy_print("Predators nearby, but no stamina to flee")
			set_desired_position(clamp_position(position))
			stamina = min(stamina + 2, max_stamina)
			return
	else:
		telepathy_print("No predators nearby, regain stamina")
		stamina = min(stamina + 1, max_stamina)
	
	## FOOD SEARCH
	# If the animal is hungry, look for the nearest prey and target a close one
	if is_hungry and len(nearby_prey) > 0:
		# Sort the prey options by distance to help decide
		nearby_prey.sort_custom(func(a, b):
			return position.distance_to(a.position) < position.distance_to(b.position)
		)
		
		# Determine which prey to target (should be close, but need not be the closest)
		var i = get_random_portion(len(nearby_prey), 0, 0.25)
		telepathy_print("Found prey! " + nearby_prey[i].species)
		set_desired_position(clamp_position(nearby_prey[i].position))
		return
	
	## SOCIAL INTERACTION
	# Sort the animals of the same species by distance
	nearby_friends.sort_custom(func(a, b):
		return position.distance_to(a.position) < position.distance_to(b.position)
	)
	
	# Check if this animal should move towards a mate
	if gender == "Male":
		for friend in nearby_friends:
			if friend.gender == "Female" and friend.reproduction_timer <= 1:
				telepathy_print("Moving to a nearby mate")
				set_desired_position(clamp_position(friend.position))
				return

	# Check if the size of the social group is too large
	if len(nearby_friends) >= social_group_size:
		var leave_group_direction = Vector3()
		for friend in nearby_friends:
			if position.distance_to(friend.position) <= social_range:
				# Add the vectors, so that an animal can flee from multiple predators at once
				leave_group_direction += (position - friend.position).normalized()
		# If there are predators nearby, flee in the opposite direction
		if leave_group_direction.length() > 0:
			var flee_direction = leave_group_direction.normalized()
			var flee_target_position = position + (flee_direction * adjusted_eye_sight)
			telepathy_print("Predators nearby, running away!")
			set_desired_position(clamp_position(flee_target_position))
			return
	elif is_lonely and len(nearby_friends) > 0: # If the animal is lonely, look for the nearest friend and target a close one
		# Determine which friend to target (should be close, but need not be the closest)
		var i = get_random_portion(len(nearby_friends), 0, 0.25)
		telepathy_print("Moving towards some friends!")
		set_desired_position(clamp_position(nearby_friends[i].position))
		return
	
	## RANDOM BEHAVIOR
	# At this point, the animal should just do something random.
	var random_choice = randi_range(1, 5)
	# Chance to stand still
	if random_choice == 1:
		telepathy_print("Nothing to do... Standing still")
		set_desired_position(clamp_position(position))
	# Chance to go somewhere random
	if random_choice == 2:
		telepathy_print("Nothing to do... Going somewhere random!")
		set_random_destination()
	# Chance to continue towards previous destination
	if random_choice >= 3:
		telepathy_print("Nothing to do... Moving towards desired position")
		pass


func decide_movement():
	# Set a value to help animals decide when to seek food / friends
	var hunger_threshold = 0.4
	var social_threshold = 0.3
	
	# Find current percentage of all needs
	var is_hungry = (float(hunger) / float(max_hunger)) < hunger_threshold
	var is_lonely = (float(social) / float(max_social)) < social_threshold
	
	var nearby_entities = eye_sight_area.get_overlapping_areas()
	
	# Organize nearby entities into predators, friends, or prey
	var nearby_prey: Array
	var nearby_predators: Array
	var nearby_friends: Array
	for entity_area3d in nearby_entities:
		var entity = entity_area3d.get_parent()
		if entity.species in prey_organisms:
			nearby_prey.append(entity)
		elif "prey_organisms" in entity and species in entity.prey_organisms:
			nearby_predators.append(entity)
		elif entity.species == species:
			nearby_friends.append(entity)
	
	## PREDATOR AWARENESS
	# Scan for nearby predators. If any are dangerously close, flee away
	var threat_direction = Vector3()
	for predator in nearby_predators:
		if position.distance_to(predator.position) <= (0.5 * adjusted_eye_sight):
			# Add the vectors, so that an animal can flee from multiple predators at once
			threat_direction += (position - predator.position).normalized()
	# If there are predators nearby, flee in the opposite direction
	if threat_direction.length() > 0:
		var flee_direction = threat_direction.normalized()
		var flee_target_position = position + (flee_direction * adjusted_eye_sight)
		telepathy_print("Predators nearby, running away!")
		set_desired_position(clamp_position(flee_target_position))
		# No other locations should be considered when predators are nearby
		return
	
	## FOOD SEARCH
	# If the animal is hungry, look for the nearest prey and target a close one
	if is_hungry and len(nearby_prey) > 0:
		# Sort the prey options by distance to help decide
		nearby_prey.sort_custom(func(a, b):
			return position.distance_to(a.position) < position.distance_to(b.position)
		)
		
		# Determine which prey to target (should be close, but need not be the closest)
		var i = get_random_portion(len(nearby_prey), 0, 0.25)
		telepathy_print("Found prey! " + nearby_prey[i].species)
		set_desired_position(clamp_position(nearby_prey[i].position))
		return
	
	## SOCIAL INTERACTION
	# Sort the animals of the same species by distance
	nearby_friends.sort_custom(func(a, b):
		return position.distance_to(a.position) < position.distance_to(b.position)
	)
	
	# Check if this animal should move towards a mate
	if gender == "Male":
		for friend in nearby_friends:
			if friend.gender == "Female" and friend.reproduction_timer <= 1:
				telepathy_print("Moving to a nearby mate")
				set_desired_position(clamp_position(friend.position))
				return

	# If the animal is lonely, look for the nearest friend and target a close one
	if is_lonely and len(nearby_friends) > 0:
		# Determine which friend to target (should be close, but need not be the closest)
		var i = get_random_portion(len(nearby_friends), 0, 0.25)
		telepathy_print("Moving towards some friends!")
		set_desired_position(clamp_position(nearby_friends[i].position))
		return
	
	## RANDOM BEHAVIOR
	# At this point, the animal should just do something random.
	var random_choice = randi_range(1, 5)
	# Chance to stand still
	if random_choice == 1:
		telepathy_print("Nothing to do... Standing still")
		set_desired_position(clamp_position(position))
	# Chance to go somewhere random
	if random_choice == 2:
		telepathy_print("Nothing to do... Going somewhere random!")
		set_random_destination()
	# Chance to continue towards previous destination
	if random_choice >= 3:
		telepathy_print("Nothing to do... Moving towards desired position")
		pass


func decide_movement_OLD():

	# Set a value to help animals decide when to seek food / friends
	var hunger_threshold = 0.4
	var social_threshold = 0.3
	
	# Find current percentage of all needs
	var hunger_percent = float(hunger) / float(max_hunger)
	var social_percent = float(social) / float(max_social)
	
	# The animal will move towards needs with a percentage lower than its threshold
	
	# Find all nearby entities, make a list of them, and score them based on their distance
	# Don't forget about predators and max social group size
	var all_entities = get_tree().get_nodes_in_group("animals") + get_tree().get_nodes_in_group("plants")
	
	# Find all predators that eat this animal, store their positions
	var predator_locations = []
	for entity in all_entities:
		# Check if this entity has prey, and if this animal is included!
		if "prey_organisms" in entity and species in entity.prey_organisms:
			predator_locations.append(entity.position)
	
	# Find all entities that are in range
	var entities_in_range = []
	for entity in all_entities:
		if position.distance_to(entity.position) <= adjusted_eye_sight:
			entities_in_range.append(entity)
	
	# Score each entity based on their distance
	# If a predator is nearby, set a negative score
	# If there are too many of this animal nearby, set a negative score
	var scored_entities = []
	var score
	for entity in entities_in_range:
		if entity.species == species or entity.species in prey_organisms:
			# Score this entity based on distance
			score = position.distance_to(entity.position)
			
			# If there are predators close to this entity, give it a negative score
			for predator in predator_locations:
				if entity.position.distance_to(predator) <= adjusted_eye_sight:
					score = -100
			
			# If there are too many of this species nearby, give this entity a negative score
			# TODO: Should a deer avoid large groups of deer, or is it avoiding large groups of grass?
			var same_species_count = 0
			for other_entity in entities_in_range:
				if other_entity.species == species:
					same_species_count += 1
			if same_species_count >= social_group_size:
				score = -100
			
			# Finally, save this entity and its score
			if score >= 0:
				scored_entities.append({"entity": entity, "score": score})
	
	var temp
	# Sort the scored entities by their score
	for i in range(scored_entities.size()):
		for j in range(scored_entities.size() - 1):
			if scored_entities[j].score > scored_entities[j+1].score:
				temp = scored_entities[j]
				scored_entities[j] = scored_entities[j+1]
				scored_entities[j+1] = temp

	# If the animal is hungry, move towards food
	if hunger_percent < hunger_threshold:
		for entity in scored_entities:
			entity = entity.entity
			if entity.species in prey_organisms:
				set_desired_position(clamp_position(entity.position))
				return
	
	# If the animal is lonely, move towards social
	elif social_percent < social_threshold:
		for entity in scored_entities:
			entity = entity.entity
			if entity.species == species:
				set_desired_position(clamp_position(entity.position))
				return
	
	# If the animal is neither hungry nor lonely
	else:
		for entity in scored_entities:
			if entity.score <= 0:
				continue
			entity = entity.entity
			if entity.species == species and entity.gender == "Female" and entity.reproduction_timer <= 1: # move towards mate
				set_desired_position(clamp_position(entity.position))
				return
		set_random_destination()


func consumed():
	telepathy_print("Oops! Dying...")
	animation_action = "dying"
	# TODO: Add some delay to allow the animation to complete
	# TODO: Placeholder 'effect' and timeout
	mesh_instance.mesh = CapsuleMesh.new()
	mesh_instance.mesh.material = StandardMaterial3D.new()
	mesh_instance.mesh.material.albedo_color = Color(0.45, 0.05, 0.05)
	await get_tree().create_timer(0.5).timeout
	queue_free()


func decrease_hunger(amount):
	hunger -= amount


func is_starved() -> bool:
	return hunger <= 0


func is_old() -> bool:
	return age >= max_age


func get_random_portion(value, low, high):
	var random_portion = randf_range(low, high)
	return value * random_portion


func clamp_position(target_position):
	var clamped_position = target_position
	clamped_position.x = clampf(clamped_position.x, grid_bounds_min, grid_bounds_max)
	clamped_position.z = clampf(clamped_position.z, grid_bounds_min, grid_bounds_max)
	return clamped_position


# Position the entity based on a 2d grid
# Note: we set position.z because in 3d, y refers to up/down
func set_grid_position(grid_x, grid_y):
	position.x = grid_x * OhioEcosystemData.grid_scale
	position.z = grid_y * OhioEcosystemData.grid_scale
	position.x += randf_range(-half_tile, half_tile)
	position.z += randf_range(-half_tile, half_tile)
	set_random_destination()


# Update where the animal is trying to walk (include some randomness)
func set_desired_position(input_position):
	desired_position = input_position
	var movement_random_variation = 2
	var change_x = randf_range(-movement_random_variation, movement_random_variation)
	var change_y = randf_range(-movement_random_variation, movement_random_variation)
	var change_z = randf_range(-movement_random_variation, movement_random_variation)
	desired_position += Vector3(change_x, change_y, change_z)
	desired_position = clamp_position(desired_position)
	telepathy_print("Desired position is now " + str(desired_position))
	telepathy_print("My current location is at " + str(position))


func set_random_destination():
	var desired_x = (randi() % OhioEcosystemData.grid_size) * OhioEcosystemData.grid_scale
	var desired_z = (randi() % OhioEcosystemData.grid_size) * OhioEcosystemData.grid_scale
	desired_x += randf_range(-half_tile, half_tile)
	desired_z += randf_range(-half_tile, half_tile)
	telepathy_print("Random destination: " + str(Vector3(desired_x, 0, desired_z)))
	set_desired_position(clamp_position(Vector3(desired_x, 0, desired_z)))


func telepathy_print(text):
	if animal_name == debug_telepathy_target:
		print("DEBUG TELEPATHY: ", text)
