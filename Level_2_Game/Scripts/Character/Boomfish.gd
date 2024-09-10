extends KinematicBody2D

#State variables
enum {
	IDLE
	PURSUIT
	EXPLODE
	OFF
}
var b_state = IDLE #IDLE, PURSUIT, ATTACK, BITE
#IDLE state means move around set area
#PURSUIT state means approach the player
#ATTACK state means go in to attack the player
#BITE state means run bting code and turn on hitbox

#Movement Variables
export var SPEED = 125
export var OFFSET_DIR = 64.3985
var save_pos = Vector2.ZERO #Position for idle state
var motion = Vector2.ZERO #Movement variable for idle state
var velocity = Vector2.ZERO #Movement variable
var cal_rotation = 0


var time = 0
var time_offset = randi()

#Other variables
export var hp = 4
export var b_scale = 0.09
var hit = false
var explode := false

var ran_num
var onScreen := false

export var _death_particle = preload("res://Scenes/Other/Explode_Particle.tscn")
export var _explode_effect = preload("res://Scenes/Enviroment/Explode.tscn")
onready var audio1 := $AudioStreamPlayer2D1
onready var audio2 := $AudioStreamPlayer2D2

func _ready():
	save_pos = self.position
	scale = Vector2(1, 1)
	
	#Prep health bar visual
	hp = 2 + global_map.diff_mode
	$Health_Bar.max_value = hp
	$Health_Bar.value = hp
	$Health_Bar.visible = false
	
	#Prep collisions
	$Player_Detection.scale = Vector2(1, 1)
	
	if global_map.opt_mode == true: $Particles2D.amount = 9
	else: $Particles2D.amount = 6
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	ran_num = rng.randf()
	
func _physics_process(delta):
	time += delta
	
	if onScreen == false && b_state == IDLE: b_state = OFF
	
	match b_state: #Movement & direction control for each enemy state
		IDLE: #IDLE STATE (Not attacking)
			idle_location(1, 75, 0.25)
			boom_direction(motion, 0.01)
			idle_location(0, 75, 0.25)
			boom_move(motion, 50, 60)
		
		PURSUIT: #PURSUE STATE (Chasing player, can loose sight)
			boom_direction(global_map.GLOBAL_p_pos, 0.025)
			boom_move(global_map.GLOBAL_p_pos, 260, 35)
			
		EXPLODE: #PURSUE STATE (Chasing player, can loose sight)
			boom_direction(global_map.GLOBAL_p_pos, 0.025)
			boom_move(global_map.GLOBAL_p_pos, 390, 25)
			
		OFF:
			pass

#Boomfish Direction
func boom_direction(target, rot_speed):
	var target_pos = target - position
	var angle = target_pos.angle()
	cal_rotation = lerp_angle(cal_rotation, angle, rot_speed) #Smooth rotation
	
	$Sprite.global_rotation = cal_rotation #Apply rotation to sprite & Collisions
	$CollisionShape2D.global_rotation = cal_rotation - 64.3985
	$Player_Detection.global_rotation = cal_rotation
	$Hitbox.global_rotation = cal_rotation
	
	
	var b_sprite_pos = $Sprite.position.x
	$Sprite.scale.x = b_scale / 2.1
	if b_sprite_pos <= target_pos.x : $Sprite.scale.y = b_scale / 2
	else: $Sprite.scale.y = -b_scale / 2

func boom_move(target, max_speed, speed_friction): #Boomfish movement
	SPEED += (max_speed - SPEED) / speed_friction
	var target_pos = (target - position).normalized()
	velocity += Vector2(((target_pos - velocity) / 5))
	var _error = move_and_slide(velocity * SPEED)

func idle_location(extra_offset, distance, speed): #Idle state movement
	motion.x = save_pos.x + (sin((time + time_offset + extra_offset) * speed) * distance)
	motion.y = save_pos.y + (cos((time + time_offset + extra_offset) * speed) * distance)

#Large Radius Detection
func _on_Player_Detection_body_entered(body): #Pursue player when in view
	if "Player" in body.name && b_state == IDLE: attack_and_explode()

func attack_and_explode(): #Aggro the fish
	b_state = PURSUIT
	
	yield(get_tree().create_timer(2.25), "timeout") #Timer till explosion
	b_state = EXPLODE
	save_pos = global_map.GLOBAL_p_pos
	
	death_flash(0.11)
	if explode == false:
		explode = true
		audio1.play()
	
	yield(get_tree().create_timer(1), "timeout") #Timer till explosion
	global_map.GLOBAL_screen_shake = true 
	
	_kill()

#Hitbox HP
func _on_Hitbox_body_entered(body): #If hit by bullet (will pursue player)
	if "Explode_Holder2" in body.name: _kill()
	else:
		if hit == false:
			hp -= 1 #Lower HP
			$Health_Bar.value = hp #Update Health Bar
			
			SPEED = -125
			if b_state == IDLE : attack_and_explode()

			if hp < 1: _kill() #Delete if HP < 1 (if no health)
			else: 
				audio2.play()
				health_bar_vis()

func health_bar_vis(): #Invincibility delay & health bar visibility
	$Health_Bar.visible = true
	hit = true
	yield(get_tree().create_timer(0.25, false), "timeout") #No-hit delay
	hit = false
	yield(get_tree().create_timer(0.75, false), "timeout")
	if hit == false: $Health_Bar.visible = false #Hide Health if not just hit

func create_particle(particle_type, p_rotation, p_scale, particle):
	var _particle = particle_type.instance()
	_particle.position = self.position
	_particle.rotation = p_rotation
	_particle.scale = Vector2(p_scale, p_scale)
	if particle == true : 
		_particle.emitting = true
	else: pass
	get_tree().current_scene.call_deferred("add_child", _particle)

func _kill(): #Kill Enemy
	create_particle(_death_particle, 0, 1, true)
	create_particle(_explode_effect, 0, 2.4, false)
	
	queue_free()

func death_flash(delay):
	for loop in range(0,4): #Flash before exploding
		yield(get_tree().create_timer(delay, false), "timeout")
		$Sprite.modulate = Color((loop * loop) + 2, (loop * loop) + 2, (loop * loop) + 2)
		
		yield(get_tree().create_timer(delay, false), "timeout")
		$Sprite.modulate = Color((loop * loop) + 2, 1, 1)

#Hide if not on screen. 
func _on_Visibilty_Box_viewport_entered(_viewport): 
	visible = true
	$Particles2D.emitting = true
	
	onScreen = true
	
	if b_state == OFF: b_state = IDLE

func _on_Visibilty_Box_viewport_exited(_viewport):
	visible = false
	$Particles2D.emitting = false
	
	onScreen = false

