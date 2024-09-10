extends Node2D

#Tex is short for texture
var tex_1 = preload("res://Assets/Entity/plants/Plant_1.png")
var tex_2 = preload("res://Assets/Entity/plants/Plant_2.png")
var tex_3 = preload("res://Assets/Entity/plants/Plant_3.png")

var tex_ar = [tex_1, tex_2, tex_3]

var tex_sel
var plant_size 
var plant_length 

onready var anim = $Plant_Animation

func _ready():
	#Randomly select a texture from the array
	tex_sel = tex_ar[rand_range(0, tex_ar.size())]
	
	#Apply textures
	get_node("1").texture = tex_sel
	get_node("1/2").texture = tex_sel
	get_node("1/2/3").texture = tex_sel
	get_node("1/2/3/4").texture = tex_sel
	get_node("1/2/3/4/5").texture = tex_sel
	get_node("1/2/3/4/5/6").texture = tex_sel
	get_node("1/2/3/4/5/6/7").texture = tex_sel
	
	#Randomise plant size & length
	plant_size = rand_range(0.4, 0.6)
	plant_length = rand_range(2, 8)
	
	scale = Vector2(plant_size, plant_size)
	
	if plant_length < 7: get_node("1/2/3/4/5/6/7").visible = false
	if plant_length < 6: get_node("1/2/3/4/5/6").visible = false
	if plant_length < 5: get_node("1/2/3/4/5").visible = false
	if plant_length < 4: get_node("1/2/3/4").visible = false
	if plant_length < 3: get_node("1/2/3/4").visible = false
	
	anim.playback_speed = rand_range(0.5, 1.1)
	anim.play("Sway")


func _on_VisibilityNotifier2D_screen_entered(): 
	#visible = true
	anim.play("Sway")
func _on_VisibilityNotifier2D_screen_exited(): 
	#visible = false
	anim.stop(false)
