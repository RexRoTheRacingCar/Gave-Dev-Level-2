extends KinematicBody2D

#Variables in Caps is a Constant (const) & variables in lowercase is a Normal Variable (var)
#Movement Variables (p = player)
const P_ACCEL = 500
const P_FRICTION = 200
const P_ROTATION_SPEED = 0.175
onready var p_max_speed = 155
onready var p_velocity = Vector2.ZERO
onready var p_dash_wait = false

#Oxygen variables
export var OXYGEN_IDLE_DECREASE = 75
export var OXYGEN_DASH_DECREASE = 20
export var oxygen_max = 5000
export var oxygen_level = 5000
export var oxygen_increments = 6
onready var oxygen_aura = 0

#Bullet variables
const P_BULLET = preload("res://Scenes/Player/Player_Bullet.tscn") 
const P_BULLET_SPEED = 600
const P_BULLET_WAIT = 0.95
onready var p_shooting = 0 #(0 not shooting, 1 shooting, 2 arming, 3 disarming)
onready var p_can_shoot = true

#Other Variables
export var _death_particle = preload("res://Scenes/Other/Explode_Particle.tscn")
export var _zap_particle = preload("res://Scenes/Other/Zap_Particle.tscn")
onready var p_hp_hit = false
var p_hit_damage
var p_regen = true

#Animation Players
onready var legAnim := $Animation_Holder/legs
onready var arm1Anim := $Animation_Holder/arm1
onready var arm2Anim := $Animation_Holder/arm2



#Main Functions - 
func _ready():
	#Animation prep
	legAnim.play("idleKick")
	arm1Anim.play("frontArmIdle")
	arm2Anim.play("backArmIdle")
	
	#Prepare oxygen bar
	$Ex_Org/Timer_Storage/Oxygen_Timer.wait_time = oxygen_increments
	$Ex_Org/Player_UI_Layer/Oxygen_Bar.max_value = oxygen_max
	$Ex_Org/Player_UI_Layer/Oxygen_Bar.value = oxygen_level
	
	OXYGEN_IDLE_DECREASE = 25 + (global_map.diff_mode * 25)
	
	#Prepare player HP
	if global_map.diff_mode == 1: global_map.GLOBAL_p_hp = 15
	else: global_map.GLOBAL_p_hp = 10
	
	$Ex_Org/Player_UI_Layer/Health_Bar.max_value = global_map.GLOBAL_p_hp
	$Ex_Org/Player_UI_Layer/Health_Bar.value = global_map.GLOBAL_p_hp
	
	#Prepare HP regen
	p_regen = global_map.diff_mode #1 & 2 allows regen. 3 Doesn't.
	if p_regen != 3: $Ex_Org/Timer_Storage/Regen_Timer.start(global_map.diff_mode)
	
	#Prepare other player variables
	global_map.GLOBAL_dead = false
	global_map.GLOBAL_main_scene = "In_Game"
	visible = true
	$Map_Collision.disabled = false
	$Enemy_Hitbox/CollisionShape2D.disabled = false
	
	$Ex_Org/P_Effects/Particles2D.emitting = false
	$Ex_Org/P_Effects/BreathParticles2D.emitting = false
	$Ex_Org/Player_UI_Layer/Vignette.visible = true
	$Ex_Org/Player_UI_Layer/RedVignette.visible = true
	
	#Scale
	$Skeleton_Rig.scale = Vector2(0.04, 0.04)
	
	#Apply Settings
	if global_map.opt_mode == true:
		$Ex_Org/P_Effects/Particles2D.amount = 20
		$Ex_Org/P_Effects/BreathParticles2D.amount = 9
		
		$Ex_Org/Player_UI_Layer/RedVignette.visible = true
		$Ex_Org/Player_UI_Layer/RedVignette.scale = Vector2(2.5, -2.5)
		$Ex_Org/Player_UI_Layer/RedVignette.position = Vector2(960, 470)
	else:
		$Ex_Org/P_Effects/Particles2D.amount = 15
		$Ex_Org/P_Effects/BreathParticles2D.amount = 6
	
	
	#Prep UI
	ui_setup()

func _physics_process(delta):
	var p_input = Input.get_vector("left","right","up","down") #Get movement angle
	player_movement(p_input, delta) 
	player_dash(delta)
	var _error = move_and_slide(p_velocity) #Apply movement to player (Placed in error variable to prevent value return)
	prep_rotation()
	
	#Update oxygen variables
	global_map.GLOBAL_p_pos = position
	global_map.GLOBAL_p_oxygen = oxygen_level
	
	#Oxygen management
	if position.y < 0: 
		position.y += (0 - position.y) / 12
		above_water()
	elif oxygen_aura != 0: above_water()
	
	$Ex_Org/Player_UI_Layer/Oxygen_Bar.value = oxygen_level
	oxygen_check(delta)
	
	$Ex_Org/Player_UI_Layer/Health_Bar.value += (global_map.GLOBAL_p_hp - $Ex_Org/Player_UI_Layer/Health_Bar.value) / 3
	global_map.GLOBAL_p_hp = clamp(global_map.GLOBAL_p_hp, -1, $Ex_Org/Player_UI_Layer/Health_Bar.max_value)
	
	depth_manage()
	
	anim()
	
func anim():
	legAnim.set_speed_scale((sqrt((p_velocity.x * p_velocity.x) + (p_velocity.y * p_velocity.y))) / 170)
	
	if p_shooting == 0 && arm1Anim.get_current_animation() != "frontArmIdle": 
		arm1Anim.play("frontArmIdle")
	
	if Input.is_action_pressed("mouse") && p_can_shoot == true: #Shooting on Click (p_shooting = true means it's shootings, false it's not)
		if p_shooting == 1:
			p_can_shoot = false
			
			arm1Anim.play("shoot")
			player_shoot()
			p_dash_stutter()
			
			yield(get_tree().create_timer(P_BULLET_WAIT, false), "timeout") #Shoot delay
			
			p_can_shoot = true
			
		elif p_shooting == 0:
			p_shooting = 2
			arm1Anim.play("frontRearm")
			yield(get_tree().create_timer(0.5, false), "timeout")
			p_shooting = 1
	
	if p_shooting == 1 and p_can_shoot == true:
		yield(get_tree().create_timer(0.1, false), "timeout")
		if p_shooting == 1 and p_can_shoot == true:
			p_shooting = 3
			arm1Anim.play("frontDisarm")
			yield(get_tree().create_timer(0.6, false), "timeout")
			p_shooting = 0

#Other Functions - 
func player_movement(p_input, delta): #Convert movement angle to actual movement
	if p_input: p_velocity = p_velocity.move_toward(p_input * p_max_speed , delta * P_ACCEL) #If moving
	else: p_velocity = p_velocity.move_toward(Vector2(0,0), delta * P_FRICTION) #If not


func player_dash(delta):
#The "if input pressed" line below is so long due to GODOT not being able to detect multiple inputs within a single action
	if p_dash_wait == false && oxygen_level > 1 && Input.is_action_pressed("dash") && (Input.is_action_pressed("right") or Input.is_action_pressed("left") or Input.is_action_pressed("up") or Input.is_action_pressed("down")): #If dashing & moving
		p_max_speed += (275 - p_max_speed) / 3  #Change top speed
		oxygen_level -= OXYGEN_DASH_DECREASE * delta#Adjust oxygen
		$Ex_Org/P_Effects/Particles2D.emitting = true
	else:
		p_max_speed += (155 - p_max_speed) / 3 #Set speed back to default
		$Ex_Org/P_Effects/Particles2D.emitting = false


func p_dash_stutter(): #Temp disable of dash after shooting
	p_dash_wait = true
	yield(get_tree().create_timer(P_BULLET_WAIT / 2, false), "timeout")
	p_dash_wait = false


func prep_rotation(): #Point towards mouse
	var p_mouse_pos = get_global_mouse_position() - global_position
	var p_angle = p_mouse_pos.angle()
	p_lerp_rot($Ex_Org/P_Effects/Light2D2, p_angle, 0.075)
	
	IK_manage(1, p_angle, p_mouse_pos)

func IK_manage(scaled, p_angle, _p_mouse_pos): #Manage IK Rig
	#Prep Scale 1
	$Skeleton_Rig/P_Skel.scale.y = scaled
	
	
	#First Rotations
	p_lerp_rot($Skeleton_Rig/P_Skel, p_angle, 0.2)
	
	var p_head_rot = p_angle + (p_angle - $Skeleton_Rig/P_Skel.global_rotation)
	
	
	
	#Prep Scale 2
	if get_global_mouse_position() >= global_position: 
		$Skeleton_Rig/P_Skel.scale.y = scaled
		p_head_rot = p_angle + (p_angle - $Skeleton_Rig/P_Skel.global_rotation)
	else: 
		$Skeleton_Rig/P_Skel.scale.y = -scaled
		p_head_rot = $Skeleton_Rig/P_Skel.global_rotation + ($Skeleton_Rig/P_Skel.global_rotation - p_angle)
	
	#Final rotations
	$Skeleton_Rig/P_Skel/Head.global_rotation = p_head_rot
	$Map_Collision.global_rotation = $Skeleton_Rig/P_Skel.global_rotation + 1.5708

#Find Rotation Angles
func p_lerp_rot(lerp_sprite, target, speed): lerp_sprite.global_rotation = lerp_angle(lerp_sprite.global_rotation, target, speed)
func p_find_p_angle(sprite, _p_angle): 
	var p2_m_pos = get_global_mouse_position() - sprite.global_position
	_p_angle = p2_m_pos.angle()

func player_shoot(): #Player shooting (Create bullet)
	var p_bullet_instance = P_BULLET.instance() #Instance variable to store data for actual bullet
	p_bullet_instance.position = $Skeleton_Rig/P_Skel/Arm_1_1/Arm_1_2/Arm_1_3/Gun.global_position #Set bullet position
	p_bullet_instance.rotation_degrees = $Skeleton_Rig/P_Skel.rotation_degrees + 180
	p_bullet_instance.apply_impulse(Vector2(),Vector2(P_BULLET_SPEED, 0).rotated($Skeleton_Rig/P_Skel.global_rotation)) #Adds velocity to bullet
	get_tree().get_root().call_deferred("add_child", p_bullet_instance) #Creates bullet instance


func _on_Oxygen_Timer_timeout(): #Oxygen Countdown
	oxygen_level -= OXYGEN_IDLE_DECREASE
	
	if position.y > 0 && oxygen_level >= 0: 
		$Ex_Org/P_Effects/BreathParticles2D.emitting = true
		yield(get_tree().create_timer(0.15, false), "timeout")
		$Ex_Org/P_Effects/BreathParticles2D.emitting = false

func _on_Regen_Timer_timeout(): #Regeneration Timeout
	if global_map.GLOBAL_dead != true:
		$Ex_Org/Timer_Storage/Regen_Timer.start(global_map.diff_mode)
		if p_regen == 1: 
			if oxygen_level >= oxygen_max * 0.75: global_map.GLOBAL_p_hp += 0.5
			
		elif p_regen == 2: 
			if oxygen_level >= oxygen_max * 0.85: global_map.GLOBAL_p_hp += 0.5


func oxygen_check(delta):
	if global_map.GLOBAL_p_hp <= 0: end_game() #End game if no hp left
	
	oxygen_level = clamp(oxygen_level, -500, oxygen_max)
	
	if oxygen_level < 0: #HP drain if out of oxygen
		global_map.GLOBAL_p_hp -= delta / 2


#Oxygen bar increase
func above_water(): oxygen_level += ceil((oxygen_max - oxygen_level) / (oxygen_aura + 30))


func depth_manage():
	var p_depth_display = clamp(floor(position.y / 100), 0, 99999) #Calculate player depth
	$Ex_Org/Player_UI_Layer/Depth_Display.text = str("Depth: ", p_depth_display, "m") #Display depth
	
	var p_fps = Engine.get_frames_per_second() #Collect FPS from godot engine
	$Ex_Org/Player_UI_Layer/FPS_Display.text = str("FPS: ", p_fps) #Display FPS
	
	#Vignette Coloration
	$Ex_Org/Player_UI_Layer/Vignette.self_modulate = Color(0, 0, 0, (position.y / 13000) + 0.125) 
	
	if global_map.opt_mode == true: 
		var p_dam_overlay = Color(1, 1, 1, (($Ex_Org/Player_UI_Layer/Health_Bar.max_value - global_map.GLOBAL_p_hp) / 20))
		$Ex_Org/Player_UI_Layer/RedVignette.self_modulate = p_dam_overlay
		$Ex_Org/Player_UI_Layer/RedVignette/Glass_Crack.self_modulate = p_dam_overlay
	else: pass

func _on_Enemy_Hitbox_body_entered(body): #If enemy hit player
	#Detect if in oxygen source aura, react based on result
	if "Oxygen_Source" in body.name: oxygen_aura = 120
	
	if p_hp_hit == false:
		if "Explode_Holder" in body.name or "Oxygen_Source" in body.name: pass
		else: global_map.GLOBAL_screen_shake = 80 #Apply camera shake

		#Get damage based on enemy
		if "Jellyfish" in body.name: 						#Jellyfish
			p_hit_damage = 2
			create_particle(_zap_particle, 0, 0.6)
			global_map.GLOBAL_screen_shake = 175
			hit()
			
			AudioEffects.play("res://Audio/electricShock.mp3")
			
		if "B_Hit_Player" in body.name: 					#Barracuda
			p_hit_damage = 0.5 + (global_map.diff_mode / 2)
			create_particle(_death_particle, self.rotation, 0.55)
			hit()
			
			AudioEffects.play("res://Audio/hitBlood.mp3")

		if "Range_Bullet" in body.name: 					#Barracuda
			p_hit_damage = 0.5 + (global_map.diff_mode / 2)
			create_particle(_death_particle, self.rotation, 0.55)
			hit()
			
			AudioEffects.play("res://Audio/hitBlood.mp3")

		if "Explode_Holder" in body.name: 					#Explosions
			p_hit_damage = 2.5 + global_map.diff_mode
			create_particle(_death_particle, self.rotation, 0.75)
			hit()
			
			AudioEffects.play("res://Audio/hitBlood.mp3")



func hit():
		global_map.GLOBAL_p_hp -= p_hit_damage
		p_hit_damage = 0
		
		#Apply damage blur
		if global_map.opt_mode == true: global_map.GLOBAL_p_hit = true
		
		p_hp_hit = true
		yield(get_tree().create_timer(2.5, false), "timeout") #Hit delay
		p_hp_hit = false


func _on_Enemy_Hitbox_body_exited(body): #Disable oxygen gain when in aura
	if "Oxygen_Source" in body.name: oxygen_aura = 0

func create_particle(particle_type, p_rotation, p_scale):
	var _particle = particle_type.instance()
	_particle.position = self.position
	_particle.rotation = p_rotation
	_particle.scale = Vector2(p_scale, p_scale)
	_particle.emitting = true
	get_tree().current_scene.add_child(_particle)


func end_game(): #Quit Game
	set_physics_process(false)
	global_map.GLOBAL_dead = true
	visible = false
	
	#Play death sound
	AudioEffects.play("res://Audio/playerDeath.mp3")
	
	$Map_Collision.disabled = true
	$Enemy_Hitbox/CollisionShape2D.disabled = true
	
	global_map.GLOBAL_p_hp = 0
	$Ex_Org/Player_UI_Layer/Health_Bar.value = 0
	
	create_particle(_death_particle, self.rotation, 0.75)
	create_particle(_death_particle, self.rotation, 1)
	
	yield(get_tree().create_timer(3, false), "timeout") #Close Game delay
	
	var error = get_tree().change_scene("res://Scenes/Main/Menu_Screen.tscn") #Go to main scene
	global_map.GLOBAL_main_scene = "In_Menu"
	if error != 0: #Fix scene bug
		queue_free()
	queue_free()


func ui_setup(): #Fix UI to match screensize
	var screensize = global_map.GLOBAL_screensize
	#UI Bars (o2 & hp)
	$Ex_Org/Player_UI_Layer/Oxygen_Bar.margin_left = 10
	$Ex_Org/Player_UI_Layer/Oxygen_Bar.margin_right = screensize.x - 10
	
	$Ex_Org/Player_UI_Layer/Health_Bar.margin_left = 10
	$Ex_Org/Player_UI_Layer/Health_Bar.margin_right = screensize.x - 10
	
	#Overlays
	$Ex_Org/Player_UI_Layer/Vignette.position = Vector2(screensize.x / 2, screensize.y / 2)
	$Ex_Org/Player_UI_Layer/RedVignette.position = Vector2(screensize.x / 2, screensize.y / 2)
	
	$Ex_Org/Player_UI_Layer/Vignette.scale = Vector2(screensize.x / (screensize.x / 30.5), screensize.y / (screensize.y / 17.25))
	$Ex_Org/Player_UI_Layer/RedVignette.scale = Vector2(screensize.x / (screensize.x / 2.5), screensize.y / (screensize.y / -2.5))
