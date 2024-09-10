extends Sprite

func _ready():
	if global_map.opt_mode == true: visible = true
	else: visible = false
