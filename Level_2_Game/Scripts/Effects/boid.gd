extends Area2D


onready var rayFolder := $rayFolder.get_children()
onready var radiusVis := $vision/CollisionPolygon2D
var boidsISee := []
var bo_vel := Vector2.ZERO
var screensize : Vector2
var movv := 42
var repel := 250
var previous_rotation : float
var steer_calc := Vector2.ZERO

var b_type : int
#Boids types,
#1 - Boid group 1 (White)
#2 - Boid group 2 (Green)
#3 - Boid group 3 (Blue)
#4 - Predator boid (Red)

#Customisable Variables
export var bo_speed := 7
var bo_speed_2 : int = bo_speed
var bo_max_speed := bo_speed + 5
var bo_min_speed := bo_speed
export var bo_size := 0.4

export var margin = 50
export var margin_fix := Vector2(0, 0)
export var margin_max := 0.05

#Boid Fish Textures
var bTex_1 = preload("res://Scenes/Enviroment/boidAtlas/boid1Atlas.tres")
var bTex_2 = preload("res://Scenes/Enviroment/boidAtlas/boid2Atlas.tres")
var bTex_3 = preload("res://Scenes/Enviroment/boidAtlas/boid3Atlas.tres")
var bTex_4 = preload("res://Scenes/Enviroment/boidAtlas/boid4Atlas.tres")
var bTex_ar = [bTex_1, bTex_2, bTex_3, bTex_4]

var boidText = preload("res://Scenes/Other/boidTexture.tres")

onready var time := 0.0
onready var offset := 0.0


func _ready():
	randomize()
	time = rand_range(0.0, 100.0)
	offset = rand_range(0.0, 100.0)
	
	if global_map.opt_mode == true: $Particles2D.emitting = true
	else: $Particles2D.emitting = false
	
	
	bo_vel = Vector2(rand_range(5, -5), rand_range(5, -5))
	
# warning-ignore:narrowing_conversion
	b_type = round(rand_range(1, 4)) #Summon types of Boids
# warning-ignore:narrowing_conversion
	if b_type == 4: 
		b_type = round(rand_range(1, 4))
		bo_speed = 6
# warning-ignore:narrowing_conversion
	else: bo_speed = (b_type * 1.5) + 4
	
# warning-ignore:narrowing_conversion
	bo_speed_2 = bo_speed
	bo_max_speed = bo_speed + 5
	bo_min_speed = bo_speed
	
# warning-ignore:narrowing_conversion
	bo_speed = bo_speed * bo_size
	scale = Vector2(bo_size, bo_size)
	$Sprite.scale = Vector2(bo_size / 12, bo_size / 12)
	$rayFolder.scale = Vector2(bo_size + 1.5, bo_size + 1.5)
	rotation = rand_range(0, 360)
	radiusVis.scale = Vector2(2.75, 2.75)
	
	#Find boid texture
	var bTex_sel
	bTex_sel = bTex_ar[b_type - 1]
	$Sprite.texture = bTex_sel
	
	
	if b_type == 4: 
		radiusVis.scale = Vector2(3.5, 1)
		scale = Vector2(bo_size + (bo_size / 2), bo_size + (bo_size / 2))
		$rayFolder.scale = Vector2(bo_size + 2, bo_size + 2)


func _physics_process(delta) -> void:
	time += delta
	
	boids()
	checkCollision()
	bo_vel = bo_vel.normalized() * bo_speed
	move()
	
	rotation = lerp_angle(rotation, bo_vel.angle_to_point(Vector2.ZERO), 0.175)
	clamp_rotation()


func clamp_rotation(): #Smoother rotation
	var maxDeltaRotation = 1.5708
	var clampedRotation = clamp(rotation, previous_rotation - maxDeltaRotation, previous_rotation + maxDeltaRotation)
	rotation = clampedRotation 
	previous_rotation = rotation


func boids() -> void:
# warning-ignore:integer_division
	bo_speed_2 += (bo_min_speed - bo_speed_2) / 24
	
	if boidsISee:
		var numOfBoids := boidsISee.size()
		var avgVel := Vector2.ZERO
		var avgPos := Vector2.ZERO
		var steerAway := Vector2.ZERO
		
		#Boid detection loop and reaction calculations
		for boid in boidsISee:
			var seg_dis : float
			
			if boid.b_type <= 3 && b_type != 4: #Normal, unmatching normal in range
				seg_dis = 4.5
				
			if boid.b_type <= 3 && b_type == 4: #Red, normal in range
				seg_dis = 1.5
			
			if boid.b_type == b_type && b_type != 4: #Normal, matching normal in range
				seg_dis = 2
# warning-ignore:narrowing_conversion
				bo_speed_2 -= 1
			
			if boid.b_type == b_type && b_type == 4: #Red, red in range
				seg_dis = 4
# warning-ignore:narrowing_conversion
				bo_speed_2 += 1
			
			if boid.b_type == 4 && b_type <= 3: #Normal, red in range
				seg_dis = 20
				bo_speed_2 += 2
			
			
			avgPos += boid.position
			avgVel += boid.bo_vel
			
			steer(boid.global_position, seg_dis)
			steerAway -= steer_calc
		
		
		avgVel /= numOfBoids #Average Boid Direction 
		#Sine wave randomised movements
		var avgVelSine = avgVel + Vector2((sin((time + offset) * bo_speed_2) * bo_speed_2 * 1.5), (cos((time - offset) * (bo_speed_2 / 1.5)) * bo_speed_2 * 1.5))
		bo_vel += (avgVelSine - bo_vel) / 2.5
		
		avgPos /= numOfBoids #Average Boid Position
		bo_vel += (avgPos - position)
		
		steerAway /= numOfBoids #Steer from other boids
		bo_vel += (steerAway)
		
# warning-ignore:narrowing_conversion
		bo_speed_2 = clamp(bo_speed_2, bo_min_speed, bo_max_speed)
		bo_vel *= bo_speed_2


func steer(b_pos, seg_distance): #Steer away from other boids math
	steer_calc = ((b_pos - global_position) * (((movv * seg_distance) * bo_size) / (global_position - b_pos).length()))


func checkCollision() -> void:
	for ray in rayFolder: #Check each ray in raycast folder
		var r : RayCast2D = ray
		
		if r.is_colliding(): #If raycast collides with object, go opposite direction from collision point
			if r.get_collider().is_in_group("collide"):
				var magi := abs(repel / (abs((r.get_collision_point() - global_position).length() + 0.05) ))
				bo_vel -= (r.cast_to.rotated(rotation) * sqrt(magi))
			
		pass

func move() -> void: #Boid movement application
	global_position += bo_vel
#	if global_position.x < 0:
#		global_position.x = screensize.x 
#	if global_position.x > screensize.x:
#		global_position.x = 0
#	if global_position.y < 0:
#		global_position.y = screensize.y 
#	if global_position.y > screensize.y:
#		global_position.y = 0

	if global_position.y < margin: #If at surface
		margin_fix.y += margin_max
		bo_vel.y += margin_fix.y


func _on_vision_area_entered(area: Area2D) -> void: 
	if area != self and area.is_in_group("boid"): boidsISee.append(area)

func _on_vision_area_exited(area: Area2D) -> void: 
	if area and area.is_in_group("boid") and area != self: boidsISee.erase(area)



func _on_VisibilityNotifier2D_screen_entered(): 
	visible = true
	if global_map.opt_mode == true: $Particles2D.emitting = true
	
func _on_VisibilityNotifier2D_screen_exited(): 
	visible = false
	if global_map.opt_mode == true: $Particles2D.emitting = false
