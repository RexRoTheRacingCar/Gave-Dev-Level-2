extends Node2D
#W is short for WORLD
#Enemy Scenes (alphabetical order)
var W_barracuda := preload("res://Scenes/Enemy/Barracuda.tscn")
var W_boomfish := preload("res://Scenes/Enemy/Boomfish.tscn")
var W_jellyfish := preload("res://Scenes/Enemy/Jellyfish.tscn")
var W_rangefish := preload("res://Scenes/Enemy/Rangefish.tscn")

#Enviroment Scenes (alphabetical order)
var W_breakable_wall := preload("res://Scenes/Enviroment/Breakable_Wall.tscn")
var W_oxy_source := preload("res://Scenes/Enviroment/Oxygen_Source.tscn")
var W_sea_mine := preload("res://Scenes/Enviroment/Sea_Mine.tscn")

#Aesthetic Scenes (alphabetical order)
var W_boid_fish := preload("res://Scenes/Enviroment/boid.tscn")
var W_plant_sway := preload("res://Scenes/Enviroment/Plants/Plant_1.tscn")

#Positioning & Spawner Array (Set positions)
var W_spawner_array = [
	W_barracuda, -320, 1365, 0, W_barracuda, -4194, 4704, 0, W_barracuda, 6486, 8950, 0, W_barracuda, 2982, 6044, 0, W_barracuda, -7984, 12556, 0, 
	
	W_jellyfish, -942, 5201, 0, W_jellyfish, 8405, 9089, 0, W_jellyfish, 8629, 9185, 0, W_jellyfish, 9712, 8287, 0, W_jellyfish, 7186, 8977, 0,
	W_jellyfish, 9577, 8758, 0, W_jellyfish, 10344, 7757, 0, W_jellyfish, 10457, 7255, 0, W_jellyfish, 10363, 6326, 0, 
	
	W_boomfish, -6127, 9824, 0, W_boomfish, -5109, 8014, 0, W_boomfish, 541, 14147, 0, 
	
	W_rangefish, 4397, 9992, 0, W_rangefish, 4397, 9992, 0, W_rangefish, -6642, 14339, 0,
	
	W_sea_mine, 1800, 1450, 0, W_sea_mine, -3128, 15125, 0, W_sea_mine, -7320, 13550, 0, W_sea_mine, -5300, 19402, 0, 
	W_sea_mine, 2595, 6254, 0, W_sea_mine, 4046, 5796, 0, 
	
	W_breakable_wall, 2060, 1445, -12, W_breakable_wall, -3128, 15362, 90, W_breakable_wall, -7540, 13570, 24, W_breakable_wall, -5470, 19402, 6,
	
	W_plant_sway, -392, 767, 0, W_plant_sway, 6088, 9212, 0, W_plant_sway, 6178, 9242, 0, W_plant_sway, 6764, 9296, 0, W_plant_sway, 567, 17338, 0, 
	W_plant_sway, -2748, 18808, 0, W_plant_sway, 8563, 6384, 0, W_plant_sway, 8025, 6270, 0, W_plant_sway, 8108, 6268, 0, 
	
	W_oxy_source, 1016, 627, 0, W_oxy_source, -4735, 4444, 0, W_oxy_source, 8272, 6162, 0, W_oxy_source, -5905, 14412, 0
	]

func _ready():
	randomize()
	
	prep_enemies()
	
	#Create enemies
	for e_index in W_spawner_array.size() / 4: #Repeat array length
		var enemy_instance = (W_spawner_array[(e_index * 4) + 0]).instance() #Get item spawned
		enemy_instance.position.x = W_spawner_array[(e_index * 4) + 1] #Get item x pos
		enemy_instance.position.y = W_spawner_array[(e_index * 4) + 2] #Get item y pos
		enemy_instance.rotation_degrees = W_spawner_array[(e_index * 4) + 3]
		
		if enemy_instance == W_boid_fish:
			enemy_instance.b_type = round(rand_range(1, 4))
			$boidFolder.add_child(enemy_instance)

		else: add_child(enemy_instance) #Create item in scene

func prep_enemies():
	#(Randomised Positions)
	#plants
	enemy_random(713, 1295, 736, 736, 0, W_plant_sway, 4)
	enemy_random(-219, 993, 1811, 1811, 0, W_plant_sway, 10)
	enemy_random(605, -1267, 3394, 3394, 0, W_plant_sway, 16)
	enemy_random(-6234, -5200, 12297, 12297, 0, W_plant_sway, 10)
	enemy_random(1268, 268, 14433, 14433, 0, W_plant_sway, 9)
	enemy_random(-563, -152, 14576, 14576, 0, W_plant_sway, 4)
	enemy_random(-4554, -5245, 16423, 16423, 0, W_plant_sway, 5)
	enemy_random(-7170, -7571, 14264, 14264, 0, W_plant_sway, 3)
	
	#barracuda
	enemy_random(-4911, -3773, 4430, 3503, 0, W_barracuda, 3)
	enemy_random(2881, 5970, 7361, 6473, 0, W_barracuda, global_map.diff_mode + 1)
	enemy_random(-857, -2390, 18981, 19565, 0, W_barracuda, 2)
	
	#jellyfish
	enemy_random(-1250, 520, 3260, 3000, 0, W_jellyfish, 6)
	enemy_random(-715, 523, 5120, 6115, 0, W_jellyfish, 4)
	enemy_random(8884, 10055, 6532, 5827, 0, W_jellyfish, 6)
	enemy_random(8014, 8884, 5608, 6180, 0, W_jellyfish, 4)
	enemy_random(-3446, -5671, 14767, 14165, 0, W_jellyfish, 5)
	
	#boomfish
	enemy_random(-715, 523, 5120, 6115, 0, W_boomfish, 3)
	enemy_random(-3126, -3683, 6677, 7363, 0, W_boomfish, 2)
	enemy_random(-4885, -3476, 19796, 19272, 0, W_boomfish, 2)
	
	#rangefish
	enemy_random(-5213, -7369, 11489, 11972, 0, W_rangefish, global_map.diff_mode)
	enemy_random(2718, 3664, 12301, 11361, 0, W_rangefish, global_map.diff_mode + 1)
	enemy_random(-3446, -5671, 14767, 14165, 0, W_rangefish, 1)
	enemy_random(-857, -2390, 18981, 19565, 0, W_rangefish, 1)
	
	#seamine
	enemy_random(6344, 3427, 7865, 6668, 0, W_sea_mine, 5)
	enemy_random(-857, -2390, 18981, 19565, 0, W_sea_mine, 6)
	enemy_random(-4910, -3400, 19850, 19225, 0, W_sea_mine, 6)
	enemy_random(-3203, -2616, 19242, 19584, 0, W_sea_mine, 2)
	
	#boids
	enemy_random(100, 900, 1500, 1700, 0, W_boid_fish, 22)
	enemy_random(-6578, -6345, 19299, 19568, 0, W_boid_fish, 12)
	enemy_random(-5246, -4550, 16252, 16390, 0, W_boid_fish, 4)
	enemy_random(-1133, -1325, 16070, 16308, 0, W_boid_fish, 3)
	enemy_random(-3846, -5271, 14567, 14265, 0, W_boid_fish, 18)
	enemy_random(-5413, -7269, 11489, 11972, 0, W_boid_fish, 22)
	enemy_random(-48, 900, 14370, 14057, 0, W_boid_fish, 12)
	enemy_random(6810, 6213, 9212, 8696, 0, W_boid_fish, 5)
	enemy_random(-3005, -3299, 6533, 5939, 0, W_boid_fish, 12)
	enemy_random(8884, 10055, 6532, 5827, 0, W_boid_fish, 19)

func enemy_random(range_x1, range_x2, range_y1, range_y2, r_rotation, entity, amount):
	for i in amount: #Create randomised enemy positions within a set range
		W_spawner_array.append(entity)
		append_enemies(range_x1, range_x2, range_y1, range_y2, r_rotation)
		
func append_enemies(range_x1, range_x2, range_y1, range_y2, r_rotation):
	W_spawner_array.append(rand_range(range_x1, range_x2))
	W_spawner_array.append(rand_range(range_y1, range_y2))
	W_spawner_array.append(r_rotation)

func _process(_delta):
	if global_map.GLOBAL_game_end == true:
		global_map.GLOBAL_game_end = false
		
		for _i in range(0, 7):
			create_fish(-6182, 19475)
			create_fish(-5000, 19475)
			create_fish(-5000, 19875)
			create_fish(-5000, 19075)

func create_fish(pos1, pos2):
	var boomer = W_boomfish.instance()
	boomer.position = Vector2(
	rand_range(pos1 + 100, pos1 - 100), 
	rand_range(pos2 + 100, pos2 - 100)
	)
	add_child(boomer)
