extends Node


var grid_size: int = 10
var grid_scale: int = 16
var plants = []
var animals = []
var days = 0

var animals_species_data = {
	"Deer": {
		"count": 0,
		"speed": 1.5,
		"max_stamina": 5,
		"reproduction_cooldown": 14,
		"max_hunger": 20,
		"eye_sight": 8,
		"movement_chance": 1,
		"max_age": 60,
		"nutrition" : 30,
		"diet_type": "Herbivore",
		"prey_organisms": ["Grass"],
		"population_limit": 100,
		"social_group_size": 5,
		"max_social": 10,
		"litter_size": 2,
	},
	"Rabbit": {
		"count": 0,
		"speed": 2.5,
		"max_stamina": 5,
		"reproduction_cooldown": 12,
		"max_hunger": 20,
		"eye_sight": 6,
		"movement_chance": 1,
		"max_age": 40,
		"nutrition" : 25,
		"diet_type": "Herbivore",
		"prey_organisms": ["Grass"],
		"population_limit": 100,
		"social_group_size": 6,
		"max_social": 10,
		"litter_size": 2,
	},
	"EasternWolf": {
		"count": 0,
		"speed": 1.5,
		"max_stamina": 5,
		"reproduction_cooldown": 20,
		"max_hunger": 50,
		"eye_sight": 8,
		"movement_chance": 1,
		"max_age": 80,
		"nutrition" : 20,
		"diet_type": "Carnivore",
		"prey_organisms": ["Deer", "Rabbit"],
		"population_limit": 30,
		"social_group_size": 10,
		"max_social": 10,
		"litter_size": 2,
	},
	"AmericanGoldfinch": {
		"count": 0,
		"speed": 2,
		"max_stamina": 5,
		"reproduction_cooldown": 12,
		"max_hunger": 15,
		"eye_sight": 6,
		"movement_chance": 1,
		"max_age": 50,
		"nutrition" : 20,
		"diet_type": "Herbivore",
		"prey_organisms": ["Grass"],
		"population_limit": 100,
		"social_group_size": 100,
		"max_social": 10,
		"litter_size": 2,
	},
}

var plants_species_data = {
	"Grass": {
		"count": 0,
		"reproduction_cooldown": 12,
		"max_age": 100,
		"nutrition": 5,
		"cluster_range": 10,
		"max_cluster_neighbors": 10,
		"population_limit": 800,
		"extra_resilience": 0.4,
	}
}
