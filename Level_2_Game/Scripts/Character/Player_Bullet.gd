extends RigidBody2D

var on_floor = true
var onscreen = true

onready var line = $Bullet_Trail
export var length = 16
var point = Vector2()

func _ready():
	if global_map.opt_mode == true: $Particles2D.amount = 22
	else: $Particles2D.amount = 13
	line.global_rotation = 0
	
#	var b_mouse_pos = get_global_mouse_position() - position
#	rotation = b_mouse_pos.angle()

func _process(_delta): #Adjust particle system to match bullet status
	if position.y > 0 && on_floor == false && onscreen == true: $Particles2D.emitting = true
	else: $Particles2D.emitting = false
		
	if global_map.GLOBAL_main_scene == "In_Menu": queue_free() #Deletes bullet when in menu screen
	
	bullet_trail()
	
	
func bullet_trail():
	var point_pos = Vector2($trailPos.global_position.x, $trailPos.global_position.y)
	line.global_position = Vector2(0, 0)
	line.global_rotation = 0
	
	point = point_pos #Find trail posision
	line.add_point(point) #Add trail
	
	while line.get_point_count() > length: #Delete trail over certain length
		line.remove_point(0) 
		

func _on_Timer_timeout(): queue_free() #Deletes bullet

#Bullet on ground status
func _on_Area2D_body_entered(_body): on_floor = true
func _on_Area2D_body_exited(_body): on_floor = false
 
func _on_Visibilty_Box_viewport_exited(_viewport): queue_free() #Deletes bullet

func _on_Collision_Vis_viewport_entered(_viewport): onscreen = true
func _on_Collision_Vis_viewport_exited(_viewport): onscreen = false
