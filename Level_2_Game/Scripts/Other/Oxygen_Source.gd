extends KinematicBody2D

var time = 0
onready var onscreen = false

func _ready():
	time = 0
	if global_map.opt_mode == true: $Particle_Aura.amount = 240
	else: $Particle_Aura.amount = 120
	
	$Particle_Aura.scale = Vector2(2, 2)

func _physics_process(delta):
	time += delta
	
	if onscreen == true:
		$Spin_Art1.rotation_degrees = time * 4
		$Spin_Art2.rotation_degrees = time * -6
		$Mid.rotation_degrees = time * 10
		
		math_anim(time, 1.35, 22, $Spin_Art1)
		math_anim(time, 1.35, 22, $Spin_Art2)
		math_anim(time, 1.35, 22, $Mid)
	else: pass
	
func math_anim(anim_time, speed, dis, item):
	item.position.x = (sin((anim_time + 0.15) * speed) * dis)

func oxy_string():
	$Oxy_String1.scale = Vector2(1,1)
	$Oxy_String1.position = Vector2(0,0)
	$Oxy_String1.t_time_offset = 0
	$Oxy_String1.wave_dis = -10
	
	$Oxy_String2.scale = Vector2(1,1)
	$Oxy_String2.position = Vector2(0,0)
	$Oxy_String2.t_time_offset = 0
	$Oxy_String2.wave_dis = 10



func _on_Visibility_viewport_entered(_viewport):
	visible = true
	$Particle_Aura.emitting = true
	onscreen = true
func _on_Visibility_viewport_exited(_viewport):
	visible = false
	$Particle_Aura.emitting = false
	onscreen = false
