extends Line2D

#Tentacle varaiables
var point_array = [] 
export var t_time_offset = 0
export var length = 12
var motion_speed = 1.35 #Speed tentacles move
var motion_width = 25 #Width tentacles sway
var t_time = 0

func _process(delta):
	t_time += delta #Adjust tentacle offset
	
	tentacle_motion()

func tentacle_motion():
	point_array.clear() #Clear tentacle positions & Remove old tentacles
	
	#Find new tentacle positions
	for i in range(length):
		point_array.append(Vector2(
			(sin((t_time + t_time_offset + i) * motion_speed) * motion_width  / (i + 1)),
			10 * i
		))
	
	#Place tentacles
	points = point_array
