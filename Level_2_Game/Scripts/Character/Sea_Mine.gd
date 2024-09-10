extends KinematicBody2D

var save_pos = Vector2.ZERO
var motion = Vector2.ZERO

var time = 0
var time_offset = randi()
var delta_match = 0

var rotation_shake = 0
var scale_shake = 0
const sea_mine_delay = 0.11
var sm_cd = 0 #sm = Seamine
var sm_flash = true 
var sm_active = false

var s_hit = false #If the seamine has been activated yet
onready var light_ex = 0
var onScreen := false

#Explosion Variables
export var _explode_effect = preload("res://Scenes/Enviroment/Explode.tscn")
export var _explode_pulse = preload("res://Scenes/Other/Massive_Pulse.tscn")

onready var audio := $AudioStreamPlayer2D

func _ready(): #Set position and scale
	save_pos = position
	scale = Vector2(2.5, 2.5)
	
	rotation_shake = 0
	scale_shake = 0
	
	$CD_Timer.wait_time = sea_mine_delay
	$Light2D.visible = false
	$Light2D.enabled = false
	
	if global_map.opt_mode == true: $Particles2D.amount = 8
	else: $Particles2D.amount = 6

func _physics_process(delta):
	time += delta 
	delta_match = delta
	var sprite_scale = clamp(scale_shake + 0.2, 0, 0.4)
	
	if onScreen == true:
		mine_movement(time_offset, 75, 0.5) 
		position.y = motion.y
		
		$Sprite.rotation_degrees = rand_range(rotation_shake, rotation_shake * -1)
		$Sprite.scale = Vector2(sprite_scale, sprite_scale)
	else: pass
	
	if global_map.opt_mode == true:
		$Light2D.texture_scale = (sprite_scale * 1.2) + 0.75
		
		if $Light2D.color == Color((sm_cd) + 3, 1, 1): $Light2D.energy = sprite_scale * 2.2
		else: $Light2D.energy = sprite_scale * 1.25

func mine_movement(extra_offset, distance, speed): #Up and down movement
	motion.y = save_pos.y + (cos((time + time_offset + extra_offset) * speed) * distance)

func create_particle(particle_type, p_rotation, p_scale, particle):
	var _particle = particle_type.instance()
	_particle.position = self.position
	_particle.rotation = p_rotation
	_particle.scale = Vector2(p_scale, p_scale)
	if particle == true : 
		_particle.emitting = true
	else: pass
	get_tree().current_scene.call_deferred("add_child", _particle)

func _kill(): #Start explosion countdown
	if sm_active == false:
		$CD_Timer.start(sea_mine_delay)
		audio.play()
	
	sm_active = true
	
	

func _on_Player_Detection_body_entered(body):
	#Will only explode if it hit by bullet or player (& isn't already active)
	if s_hit == false && "Player" in body.name or "Bullet_body" in body.name or "Explode_Holder2" in body.name: _kill()
	else: pass

#Hide if not on screen. 
func _on_Visibilty_Box_viewport_entered(_viewport): 
	visible = true
	onScreen = true
	
func _on_Visibilty_Box_viewport_exited(_viewport): 
	visible = false
	onScreen = false


func _on_CD_Timer_timeout():
	if global_map.opt_mode == true: 
		$Light2D.visible = true
		$Light2D.enabled = true
	sm_cd += 1
	
	if sm_cd >= 9: #Explode if flashed long enough
		create_particle(_explode_effect, 0, 4, false)
		if global_map.opt_mode == true: create_particle(_explode_pulse, 0, 1, false)
		
		queue_free()
	
	else: #Keep flashing
		$CD_Timer.start(sea_mine_delay)
		
		rotation_shake += 0.7
		sm_flash = !sm_flash
		
		if sm_flash == false:								#Flash white
			scale_shake += delta_match / 2
			$Sprite.modulate = Color((sm_cd) + 2, (sm_cd) + 2, (sm_cd) + 2)
			if global_map.opt_mode == true: $Light2D.color = Color((sm_cd) + 2, (sm_cd) + 2, (sm_cd) + 2)
			
		else: 												#Flash red
			$Sprite.modulate = Color((sm_cd) + 2, 1, 1)
			if global_map.opt_mode == true: $Light2D.color = Color((sm_cd) + 3, 1, 1)
