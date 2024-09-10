extends Line2D

export var length = 24 #Set trail length
var point = Vector2()

func _process(_delta):
	global_position = Vector2(0,0) 
	global_rotation = 0
	
	point = get_parent().global_position #Find trail posision
	
	add_point(point) #Add trail
	while get_point_count() > length: #Delete trail over certain length
		remove_point(0) 
	
	 
