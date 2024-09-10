extends KinematicBody2D

#Jellyfish variables
const JELLY_RADIUS = 45
const JELLY_SPEED = 1
var jelly_pos = Vector2.ZERO
var jelly_move_x = 0
var jelly_move_y = 0

#Jellyfish movement & movement offset
var time = 0
var time_offset = randi()

var onScreen := false

#Jellyfish HP
export var j_hp = 5
var jelly_hit = false

export var _death_particle = preload("res://Scenes/Other/Explode_Particle.tscn")

onready var audio := $AudioStreamPlayer2D

func _ready():
	jelly_pos = position
	scale = Vector2(1, 1)
	
	#Prep health bar visual
	j_hp = 2 + global_map.diff_mode
	$Health_Bar.max_value = j_hp
	$Health_Bar.value = j_hp
	$Health_Bar.visible = false
	
	#Prep Jellyfish Tentacles
	tentacle_prep()

func _physics_process(delta):
	get_position_values(delta)
	
	if onScreen == true:
		#Apply position
		position.x = jelly_move_x
		position.y = jelly_move_y
		
		#Slight rotating animation
		rotation_degrees = (sin((time + 2.5 + time_offset) * JELLY_SPEED/1.75) * 10)
		
		#Sprite Animation
		$Sprite.position.y = -5 + (sin((time + time_offset) * -JELLY_SPEED) * 5)
		$Sprite.scale.x = 0.65 + (sin((time + time_offset) * -JELLY_SPEED) * 0.1)
		$Sprite.scale.y = 0.65 + -(sin((time + time_offset) * -JELLY_SPEED) * 0.1)
		
		#Health Bar Fix
		$Health_Bar.rect_rotation = rotation_degrees * -1
	else: pass
	
func get_position_values(delta): #Get jellyfish position
	time += delta 
	#Use sine / cosine waves for jellyfish position
	jelly_move_x = jelly_pos.x + (sin((time + time_offset) * JELLY_SPEED / 1.75) * JELLY_RADIUS)
	jelly_move_y = jelly_pos.y + (cos((time + time_offset) * JELLY_SPEED) * JELLY_RADIUS) 


func _on_Hitbox_body_entered(body): #If hit by bullet
	if "Explode_Holder2" in body.name: _kill()
	else:
		if jelly_hit == false:
			j_hp -= 1 #Lower HP
			$Health_Bar.value = j_hp #Update Health Bar
			
			if j_hp < 1: #Delete if HP < 1 (if no health)
				_kill()
				
			else:
				audio.play()
				health_bar_vis()

func health_bar_vis(): #Invincibility delay & health bar visibility
	$Health_Bar.visible = true
	jelly_hit = true
	yield(get_tree().create_timer(0.25), "timeout") #No-hit delay
	jelly_hit = false
	yield(get_tree().create_timer(0.75), "timeout")
	if jelly_hit == false: $Health_Bar.visible = false #Hide Health if not just hit
	
func _kill(): #Kill Enemy
	var _particle = _death_particle.instance()
	_particle.position = self.position
	_particle.rotation = self.rotation
	_particle.scale = Vector2(0.75, 0.75)
	_particle.emitting = true
	get_tree().current_scene.add_child(_particle)
	
	queue_free()


func tentacle_prep(): #Prepare jellyfish tentacles
	var _s_com = 1
	
	$Tentacle_1.scale = Vector2(_s_com, _s_com)
	$Tentacle_1.position = Vector2(0,0)
	$Tentacle_1.t_time_offset = randi()
	$Tentacle_1.wave_dis = 10
	
	$Tentacle_2.scale = Vector2(_s_com - 0.25, _s_com - 0.25)
	$Tentacle_2.position = Vector2(15,0)
	$Tentacle_2.t_time_offset = randi()
	$Tentacle_2.wave_dis = 10
	
	$Tentacle_3.scale = Vector2(_s_com - 0.25,_s_com - 0.25)
	$Tentacle_3.position = Vector2(-15,0)
	$Tentacle_3.t_time_offset = randi()
	$Tentacle_3.wave_dis = 10
	
	$Background_Tentacle.scale = Vector2(_s_com, _s_com)
	$Background_Tentacle.position = Vector2(0,0)
	$Background_Tentacle.t_time_offset = randi()
	$Background_Tentacle.length = 16
	$Background_Tentacle.wave_dis = 10

#Hide if not on screen. 
func _on_Visibilty_Box_viewport_entered(_viewport): 
	visible = true
	$Particles2D.emitting = true
	
	onScreen = true

func _on_Visibilty_Box_viewport_exited(_viewport): 
	visible = false
	$Particles2D.emitting = false
	onScreen = false


