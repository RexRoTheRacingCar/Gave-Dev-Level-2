extends Particles2D


func _ready():
	if global_map.opt_mode == true: amount = 450
	else: amount = 250
	
	emitting = true

func _process(_delta):
	position.x = global_map.GLOBAL_p_pos.x
	position.y = clamp(global_map.GLOBAL_p_pos.y, 1080, 999999)
