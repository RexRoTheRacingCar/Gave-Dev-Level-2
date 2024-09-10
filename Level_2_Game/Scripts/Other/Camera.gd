extends Camera2D

# "c" means camera
export var c_mouse_reach = 4.5 #The distance you can see away from the player
var c_dis_sens = (global_map.GLOBAL_screensize.x / 1920) * 650
#Mouse distance from player, sensitivity (420 for laptop, 650 for school computers) #Ignore
var c_mouse_pos = Vector2()
var shake = 0
var c_mouse_dis = 0
var c_mouse_zoom = 0

func _ready():
	shake = 0
	smoothing_speed = 3 #Set camera smoothness
	c_mouse_zoom = 10
	zoom = Vector2(1, 1)
	rotation_degrees = 0

func _process(_delta):
	if global_map.GLOBAL_screen_shake != 0: camera_shake()
	
	if global_map.GLOBAL_dead == false:
		get_camera_zoom()
		get_camera_pos()
		
		position = c_mouse_pos #Apply camera position
	else:
		c_mouse_zoom += (0.6 - c_mouse_zoom) / 30
		zoom = Vector2(c_mouse_zoom, c_mouse_zoom)
		
		c_mouse_pos.x = global_map.GLOBAL_p_pos.x + rand_range(shake, shake * -1)
		c_mouse_pos.y = global_map.GLOBAL_p_pos.y + rand_range(shake, shake * -1)
		position = c_mouse_pos

func get_camera_pos(): #Find camera position
	c_mouse_pos = get_local_mouse_position() #Go to mouse position
	c_mouse_pos.x = ((c_mouse_pos.x/c_mouse_reach) + global_map.GLOBAL_p_pos.x) + rand_range(shake, shake * -1) #Go to player X-Axis + mouse position
	c_mouse_pos.y = ((c_mouse_pos.y/c_mouse_reach) + global_map.GLOBAL_p_pos.y) + rand_range(shake, shake * -1) #Same as above with Y-Axis


func get_camera_zoom(): #Find camera zoom
	#Using Pythagorus to find the distance the player is from the mouse on an angle
	var c_pos = Vector2(c_mouse_pos.x - global_map.GLOBAL_p_pos.x, c_mouse_pos.y - global_map.GLOBAL_p_pos.y)
	c_mouse_dis = (sqrt((c_pos.x * c_pos.x) + (c_pos.y * c_pos.y)))
	
	c_mouse_dis = (c_mouse_dis / c_dis_sens) + 0.65  	#Use the value to find a suitable zoom for the viewport
	c_mouse_zoom += (c_mouse_dis - c_mouse_zoom) / 8
	
	c_mouse_zoom = clamp(c_mouse_zoom, 0.65, 1.75)  #Clamp zoom values to not go too high or low
	
	zoom = Vector2(c_mouse_zoom, c_mouse_zoom)  #Set the camera zoom

func camera_shake(): #Apply screenshake
	if global_map.shake_mode == true: shake = global_map.GLOBAL_screen_shake 
	else: pass
	yield(get_tree().create_timer(0.1), "timeout") #Close Game delay
	shake = 0 #Remove screenshake
	
	global_map.GLOBAL_screen_shake = 0

