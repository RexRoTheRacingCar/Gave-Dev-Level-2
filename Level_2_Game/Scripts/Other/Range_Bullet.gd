extends RigidBody2D

onready var line = $Bullet_Trail
export var length = 14
var point = Vector2()

onready var audio := $AudioStreamPlayer2D
onready var anim := $AnimationPlayer

func _ready():
	look_at(global_map.GLOBAL_p_pos)
	visible = true
	$Particles2D.emitting = true
	
	$Timer.start(12)
	anim.play("spawn")
	
	line.global_rotation = 0

func _process(_delta): 
	if global_map.GLOBAL_main_scene == "In_Menu": queue_free() #Deletes bullet when in menu screen
	
	bullet_trail()


func bullet_trail():
	var point_pos = Vector2($Polygon2D.global_position.x, $Polygon2D.global_position.y)
	line.global_position = Vector2(0, 0)
	line.global_rotation = 0
	
	point = point_pos #Find trail posision
	line.add_point(point) #Add trail
	
	while line.get_point_count() > length: #Delete trail `over certain length
		line.remove_point(0) 
		

func _on_Timer_timeout():
	queue_free()

func _on_VisibilityNotifier2D_screen_entered(): visible = true
func _on_VisibilityNotifier2D_screen_exited(): visible = false
