extends KinematicBody2D

#State variables
enum {
	IDLE
	PURSUIT
	SHOOT
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
var save_shoot_pos = Vector2.ZERO
var motion = Vector2.ZERO #Movement variable for idle state
var velocity = Vector2.ZERO #Movement variable
var cal_rotation = 0

var time = 0
var time_offset = randi()

#Other variables
export var hp = 4
export var b_scale = 0.052
var hit = false

var ran_num
var onScreen := false

export var _death_particle = preload("res://Scenes/Other/Explode_Particle.tscn")
export var F_BULLET = preload("res://Scenes/Enemy/Range_Bullet.tscn")

onready var audio := $AudioStreamPlayer2D

func _ready():
	save_pos = self.position
	scale = Vector2(1, 1)
	
	
	#Prep health bar visual
	hp = 3 + global_map.diff_mode
	$Node2D/Health_Bar.max_value = hp
	$Node2D/Health_Bar.value = hp
	$Node2D/Health_Bar.visible = false
	
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
			idle_location(1, 100, 0.3, save_pos)
			fish_direction(motion, 0.01)
			idle_location(0, 100, 0.3, save_pos)
			fish_move(motion, 60, 120)
		
		PURSUIT: #PURSUE STATE (Chasing player)
			fish_direction(global_map.GLOBAL_p_pos, 0.2)
			idle_location(ran_num, 200, 0.1, global_map.GLOBAL_p_pos)
			fish_move(motion, 200, 75)
			
		SHOOT: #PURSUE STATE (Chasing player, can loose sight)
			fish_direction(global_map.GLOBAL_p_pos, 0.2)
			fish_move(save_shoot_pos, 75, 60)
			
		OFF:
			pass

#Boomfish Direction
func fish_direction(target, rot_speed):
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

func fish_move(target, max_speed, speed_friction): #Boomfish movement
	SPEED += (max_speed - SPEED) / speed_friction
	var target_pos = (target - position).normalized()
	velocity += Vector2(((target_pos - velocity) / 5))
	var _error = move_and_slide(velocity * SPEED)

func idle_location(extra_offset, distance, speed, pos): #Idle state movement
	motion.x = pos.x + (sin((time + time_offset + extra_offset) * speed) * distance)
	motion.y = pos.y + (cos((time + time_offset + extra_offset) * speed) * distance)

func fish_shoot(knockback):
	SPEED = knockback
	
	var f_bullet_instance = F_BULLET.instance() #Instance variable to store data for actual bullet
	f_bullet_instance.position = global_position #Set bullet position
	f_bullet_instance.apply_impulse(Vector2(),Vector2(rand_range(400, 600), 0).rotated($Sprite.global_rotation + rand_range(0.15, -0.15))) #Adds velocity to bullet
	get_tree().get_root().call_deferred("add_child", f_bullet_instance) #Creates bullet instance

#Large Radius Detection
func _on_Player_Detection_body_entered(body): #Pursue player when in view
	if "Player" in body.name && b_state == IDLE: 
		b_state = PURSUIT
		$Timer.start(4)


func _on_Timer_timeout():
		save_shoot_pos = Vector2((global_position.x + global_map.GLOBAL_p_pos.x) / 2, (global_position.y + global_map.GLOBAL_p_pos.y) / 2)
		b_state = SHOOT
		
		var knockbackSpeed = -1 * (SPEED / 1.4)
		
		for _shoot in (1 + global_map.diff_mode):
			fish_shoot(knockbackSpeed)
			yield(get_tree().create_timer(0.35, false), "timeout")
		
		yield(get_tree().create_timer(0.5, false), "timeout")
		
		if hp <= 2:
			b_state = PURSUIT
			$Timer.start(4)
		else:
			b_state = IDLE
			save_pos = global_position


#Hitbox HP
func _on_Hitbox_body_entered(body): #If hit by bullet (will pursue player)
	if "Explode_Holder2" in body.name: _kill()
	else:
		if hit == false:
			hp -= 1 #Lower HP
			$Node2D/Health_Bar.value = hp #Update Health Bar
			
			SPEED = -125
# warning-ignore:standalone_expression
			if b_state == IDLE: 
				b_state = PURSUIT
				$Timer.start(2.5)

			if hp < 1: _kill() #Delete if HP < 1 (if no health)
			else: 
				audio.play()
				health_bar_vis()

func health_bar_vis(): #Invincibility delay & health bar visibility
	$Node2D/Health_Bar.visible = true
	hit = true
	yield(get_tree().create_timer(0.25, false), "timeout") #No-hit delay
	hit = false
	yield(get_tree().create_timer(0.75, false), "timeout")
	if hit == false: $Node2D/Health_Bar.visible = false #Hide Health if not just hit

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
	
	queue_free()

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
