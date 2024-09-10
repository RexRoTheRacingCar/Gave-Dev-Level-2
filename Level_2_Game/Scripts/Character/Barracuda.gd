extends KinematicBody2D

#State variables
enum {
	IDLE
	PURSUIT
	ATTACK
	BITE
	OFF
}
var b_state = IDLE #IDLE, PURSUIT, ATTACK, BITE
#IDLE state means move around set area
#PURSUIT state means approach the player
#ATTACK state means go in to attack the player
#BITE state means run bting code and turn on hitbox

#Movement Variables
export var B_SPEED = 125
export var B_OFFSET_DIR = 64.3985
var b_save_pos = Vector2.ZERO #Position for idle state
var b_motion = Vector2.ZERO #Movement variable for idle state
var b_velocity = Vector2.ZERO #Movement variable
var cal_rotation = 0

var time = 0
var time_offset = randi()

#Other variables
export var b_hp = 5
export var b_scale = 1
var b_hit = false
var b_attacking = false

var b_ran_num
var onScreen := false

export var _death_particle = preload("res://Scenes/Other/Explode_Particle.tscn")

onready var audio1 := $AudioStreamPlayer2D1
onready var audio2 := $AudioStreamPlayer2D2
onready var anim := $AnimationPlayer

func _ready():
	b_save_pos = self.position
	scale = Vector2(b_scale, b_scale)
	b_attacking = false
	
	#Prep health bar visual
	b_hp = 3 + global_map.diff_mode
	$Health_Bar.max_value = b_hp
	$Health_Bar.value = b_hp
	$Health_Bar.visible = false
	
	#Prep collisions
	$Player_Detection.scale = Vector2(1, 1)
	$B_Hit_Player/Hit_Collision.disabled = true
	
	if global_map.opt_mode == true: $B_Hit_Player/Particles2D.amount = 10
	else: $B_Hit_Player/Particles2D.amount = 6
	
	var b_rng = RandomNumberGenerator.new()
	b_rng.randomize()
	b_ran_num = b_rng.randf()
	
func _physics_process(delta):
	time += delta
	
	if onScreen == false && b_state == IDLE: b_state = OFF
	
	match b_state: #Movement & direction control for each enemy state
		IDLE: #IDLE STATE (Not attacking)
			idle_location(1, 65, 0.3)
			barra_direction(b_motion, 0.01)
			idle_location(0, 65, 0.3)
			barra_move(b_motion, 50, 60)
		
		PURSUIT: #PURSUE STATE (Chasing player, can loose sight)
			barra_direction(global_map.GLOBAL_p_pos, 0.025)
			barra_move(global_map.GLOBAL_p_pos, 230, 20)
		
		ATTACK: #ATTACKING STATE (Going in for a bite)
			barra_direction(global_map.GLOBAL_p_pos, 0.04)
			barra_move(global_map.GLOBAL_p_pos, 300, 4)
		
		BITE: #BITING STATE (Attempt at biting player)
			barra_direction(global_map.GLOBAL_p_pos, 0.045)
			barra_move(global_map.GLOBAL_p_pos, 460, 1)
		
		OFF:
			pass

#Barra Direction
func barra_direction(target, rot_speed):
	var b_target_pos = target - position
	var b_angle = b_target_pos.angle()
	cal_rotation = lerp_angle(cal_rotation, b_angle, rot_speed) #Smooth rotation
	
	$Sprite.global_rotation = cal_rotation #Apply rotation to sprite & Collisions
	$B_Hit_Player.global_rotation = cal_rotation
	$Body_Collision.global_rotation = cal_rotation - B_OFFSET_DIR
	$Hitbox.global_rotation = cal_rotation - B_OFFSET_DIR
	
	var b_sprite_pos = $Sprite.position.x
	
	if b_sprite_pos <= b_target_pos.x : 
		$Sprite.scale.y = (b_scale)
	else: 
		$Sprite.scale.y = -(b_scale )
	$Sprite.scale.x = (b_scale)

func barra_move(target, max_speed, speed_friction): #Barra movement
	B_SPEED += (max_speed - B_SPEED) / speed_friction
	var target_pos = (target - position).normalized()
	b_velocity += Vector2(((target_pos - b_velocity) / 5))
	var _error = move_and_slide(b_velocity * B_SPEED)

func idle_location(extra_offset, distance, speed): #Idle state movement
	b_motion.x = b_save_pos.x + (sin((time + time_offset + extra_offset) * speed) * distance)
	b_motion.y = b_save_pos.y + (cos((time + time_offset + extra_offset) * speed) * distance)


#Hitbox HP
func _on_Hitbox_body_entered(body): #If hit by bullet (will pursue player)
	if "Explode_Holder2" in body.name: _kill()
	else:
		if b_hit == false:
			b_hp -= 1 #Lower HP
			$Health_Bar.value = b_hp #Update Health Bar
			
			B_SPEED = -250
			if b_attacking == false: _b_attack()
			
			if b_hp < 1: _kill() #Delete if HP < 1 (if no health)
			else: 
				audio1.play()
				health_bar_vis()

func health_bar_vis(): #Invincibility delay & health bar visibility
	$Health_Bar.visible = true
	b_hit = true
	yield(get_tree().create_timer(0.25, false), "timeout") #No-hit delay
	b_hit = false
	yield(get_tree().create_timer(0.75, false), "timeout")
	if b_hit == false: $Health_Bar.visible = false #Hide Health if not just hit


#Large Radius Detection
func _on_Player_Detection_body_entered(body): #Pursue player when in view
	if "Player" in body.name && b_state == IDLE  && b_attacking == false:
		b_state = PURSUIT

func _on_Player_Detection_body_exited(body): #Reset if player escapes view
	if "Player" in body.name && b_state == PURSUIT:
		b_attacking = false
		b_save_pos = self.position
		b_state = IDLE

#Small Radius Detection 
func _on_Player_Attack_Box_body_entered(body):
	if "Player" in body.name && b_attacking == false && b_state == PURSUIT: #Set to attack
		_b_attack()

func _b_attack():
	b_state = ATTACK
	b_attacking = true
	
	yield(get_tree().create_timer(1.5, false), "timeout") #After timer go in for a bite
	b_state = BITE
	$B_Hit_Player/Hit_Collision.disabled = false
	
	anim.play("bite")
	audio2.play()
	
	yield(get_tree().create_timer(0.15, false), "timeout") #Go back to idle after bite
	b_attacking = false
	b_save_pos = global_map.GLOBAL_p_pos
	b_state = IDLE
	$B_Hit_Player/Hit_Collision.disabled = true
	$Player_Detection.scale = Vector2(1, 1)

func _kill(): #Kill Enemy
	var _particle = _death_particle.instance()
	_particle.position = self.position
	_particle.rotation = self.rotation
	_particle.scale = Vector2(0.9, 0.9)
	_particle.emitting = true
	get_tree().current_scene.add_child(_particle)
	
	queue_free()

#Hide if not on screen. 
func _on_Visibilty_Box_viewport_entered(_viewport): 
	visible = true
	$B_Hit_Player/Particles2D.emitting = true
	onScreen = true
	
	if b_state == OFF: b_state = IDLE
	
func _on_Visibilty_Box_viewport_exited(_viewport): 
	visible = false
	$B_Hit_Player/Particles2D.emitting = false
	onScreen = false
	
