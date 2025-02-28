extends MeshInstance3D

# Plant variables; export the ones that we want to tweak in the editor
@export var species: String
@export var self_scene_path: String

@onready var cluster_area = $ClusterDetection
@onready var cluster_collision = $ClusterDetection/ClusterDetectionCollision

var plant_name: String
var max_age: int
var age: int
var nutrition: int
var reproduction_cooldown: int
var default_reproduction_cooldown: int
var reproduction_timer: int
var cluster_range: int
var max_cluster_neighbors: int
var plant_position: Vector2
var extra_resilience: float
var max_health: float = 100.0  # Initial health
var health: float = max_health

# Competition for Space
var space_competition_threshold: int = 10  # Number of neighbors for plant to start losing health
var current_neighbors: int = 0

# Overcrowding
var max_clustering_efficiency: int = 3  # Max number of nearby plants for optimal growth
var nearby_plants_count: int = 0

var regrowing = false
var half_tile = OhioEcosystemData.grid_scale * 0.5
var grid_bounds_min = -0.5 * OhioEcosystemData.grid_scale
var grid_bounds_max = (OhioEcosystemData.grid_scale) * (OhioEcosystemData.grid_size - 0.5)

func _ready():
	# Fetch settings for this particular plant
	default_reproduction_cooldown = OhioEcosystemData.plants_species_data[species]["reproduction_cooldown"]
	max_age = OhioEcosystemData.plants_species_data[species]["max_age"]
	nutrition = OhioEcosystemData.plants_species_data[species]["nutrition"]
	cluster_range = OhioEcosystemData.plants_species_data[species]["cluster_range"]
	max_cluster_neighbors = OhioEcosystemData.plants_species_data[species]["max_cluster_neighbors"]
	extra_resilience = OhioEcosystemData.plants_species_data[species]["extra_resilience"]
	
	age = get_random_portion(max_age, 0, 0.25)
	reproduction_cooldown = get_random_portion(default_reproduction_cooldown, 0, 1)
	reproduction_timer = get_random_portion(reproduction_cooldown, 0, 1)
	health = get_random_portion(max_health, 0.5, 1)
	cluster_collision.shape.height = cluster_range
	cluster_collision.shape.radius = cluster_range

func update():
	# Don't do anything else if in the growing stage
	if regrowing:
		return
	
	age += 1
	reproduction_timer -= 1
	
	# # Competition for Space (Crowding increases, health decreases)
	# current_neighbors = cluster_area.get_overlapping_areas().size()
	# if current_neighbors > space_competition_threshold:
	# 	health -= (current_neighbors - space_competition_threshold) * 0.2  # damage for overcrowding

	# Overcrowding (Performance reduction)
	nearby_plants_count = cluster_area.get_overlapping_areas().size()
	if nearby_plants_count > max_clustering_efficiency:
		reproduction_cooldown = default_reproduction_cooldown * 2  # Increased cooldown for reproduction
	else:
		reproduction_cooldown = default_reproduction_cooldown / 4  # Normal reproduction cooldown
		reproduction_timer = 0

	# If the plant needs removed, remove it!
	if is_old():
		consumed()
		print(plant_name + " is old")
	if health <= 0:
		consumed()
		print(plant_name + " has no health")

	# Reproduce if conditions are right
	if reproduction_timer <= 0:
		var all_neighbors = cluster_area.get_overlapping_areas()
		var total_plant_neighbors = 0
		for neighbor in all_neighbors:
			if neighbor.is_in_group("plants_area"):
				total_plant_neighbors += 1

		if total_plant_neighbors <= max_cluster_neighbors:
			reproduction_timer = reproduction_cooldown
			reproduce()

func consumed():
	# Plant cannot be consumed while regrowing
	if regrowing:
		return
	
	# Chance to resist being deleted
	if randf() > extra_resilience:
		
		# Another chance to enter regrowing mode instead of being fully deleted
		if randf() > extra_resilience:
			OhioEcosystemData.plants_species_data[species]["count"] -= 1
			queue_free()
		else:
			# Plant should disappear as if eaten for some time, then it should come back
			regrowing = true
			visible = false
			health = 100
			age = get_random_portion(max_age, 0, 0.25)
			reproduction_timer = get_random_portion(reproduction_cooldown, 0, 0.25)
			remove_from_group("plants")
			
			# Wait a random amount of time
			await get_tree().create_timer(randf_range(15, 60)).timeout
			
			# The plant should now come back
			visible = true
			regrowing = false
			add_to_group("plants")

func reproduce():
	# Get the parent scene so we can add the new instance to it
	var parent = get_parent()
	assert(not parent == null)
	
	# Check that this species hasn't hit its limit
	var population_limit = OhioEcosystemData.plants_species_data[species]["population_limit"]
	if OhioEcosystemData.plants_species_data[species]["count"] >= population_limit:
		return
	
	# Create a new instance of the current scene
	var new_plant = load(self_scene_path).instantiate()

	# Set position near the original plant
	var offset = Vector3()
	offset.x = randf_range(-half_tile, half_tile)
	offset.z = randf_range(-half_tile, half_tile)
	new_plant.clamp_position(position + offset)

	# Set a name based on what number plant this is
	new_plant.plant_name = species.to_lower() + "_" + str(OhioEcosystemData.plants_species_data[species]["count"])

	# Add the new instance to the scene
	parent.add_child(new_plant)
	OhioEcosystemData.plants_species_data[species]["count"] += 1
	print(plant_name + " has reproduced")

func is_old() -> bool:
	return age >= max_age

# Position the entity based on a 2d grid
func set_grid_position(grid_x, grid_y):
	position.x = grid_x * OhioEcosystemData.grid_scale
	position.z = grid_y * OhioEcosystemData.grid_scale
	position.x += randf_range(-half_tile, half_tile)
	position.z += randf_range(-half_tile, half_tile)
	clamp_position(position)

func clamp_position(target_position):
	var clamped_position = target_position
	clamped_position.x = clampf(clamped_position.x, grid_bounds_min, grid_bounds_max)
	clamped_position.z = clampf(clamped_position.z, grid_bounds_min, grid_bounds_max)
	position = clamped_position
	return clamped_position

func get_random_portion(value, low, high):
	var random_portion = randf_range(low, high)
	return value * random_portion
