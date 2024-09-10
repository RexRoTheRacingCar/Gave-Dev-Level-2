extends Line2D

#This script is very similar to the "Jelly_Tentacle" Script
#Water  varaiables
var water_array = [] 
export var length = 200
export var motion_speed = 0.75 #Speed water moves
export var motion_height = 12.5 #Height waves move
export var wave_increments = 25 #Space between points in wave
export var wave_pos_offset = 0
var time = 0

func _process(delta):
	time += delta #Adjust wave offset
	
	water_motion()

func water_motion():
	self.water_array.clear() #Clear water position & Remove old water position
	
	#Find new water position
	for i in range(length):
		self.water_array.append(Vector2(
			(wave_increments * i) - wave_pos_offset,
			-abs(-wave_increments + (sin((time + i) * motion_speed) * motion_height))
		))
	
	#Place waves
	points = water_array
