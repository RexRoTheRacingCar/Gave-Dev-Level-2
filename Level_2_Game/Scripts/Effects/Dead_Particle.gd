extends Particles2D

func _ready():
	if global_map.opt_mode == true: amount = 75 
	else: amount = 40
