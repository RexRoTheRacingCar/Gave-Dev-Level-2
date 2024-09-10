extends Particles2D

#Enable / Disable background particles (optimisation setting)
export var partAmount = 0

func _ready():
	if global_map.opt_mode == true: amount = partAmount
	else: amount = partAmount / 2
