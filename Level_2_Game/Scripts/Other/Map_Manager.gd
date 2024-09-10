extends Node2D

#Global Settings Variables
var menu_open = false
export var opt_mode = true #True = good graphics | False = bad graphics
export var shake_mode = true #True = yes screenshake | False = no screenshake
export var bloom_mode = true #True = glowing | False = not glowing
export var diff_mode = 2 #1 = easy | 2 = medium | 3 = hard

#Exported Global Variables
export onready var GLOBAL_p_hp = 1
export onready var GLOBAL_p_oxygen = 5
export onready var GLOBAL_dead = false
export onready var GLOBAL_p_hit = false
export var GLOBAL_main_scene = " "

var map_effect = preload("res://Other/Test_Map_World.tres")

#Unxported Global Variables
var GLOBAL_p_pos = Vector2()
var GLOBAL_screen_shake = 0
var GLOBAL_game_end := false
var GLOBAL_screensize = OS.get_screen_size()
var GLOBAL_audioVolume = 1

#Variables for Script
onready var l_blur_am = 0
onready var l_time = 0

func _ready():
	map_effect.dof_blur_near_enabled = true
	map_effect.dof_blur_near_distance = 2
	map_effect.dof_blur_near_transition = 1
	map_effect.dof_blur_near_amount = l_blur_am
	
	if global_map.bloom_mode == true: map_effect.glow_enabled = true
	else: map_effect.glow_enabled = false

func _process(_delta):
	if global_map.opt_mode == true:
		l_blur_am += (0 - l_blur_am) / 40
		map_effect.dof_blur_near_amount = (floor(l_blur_am * 100)) / 110
		
		if global_map.GLOBAL_p_hit == true: blur()


func blur():
	l_blur_am = 0.8 / clamp((global_map.GLOBAL_p_hp + 2), 2, 999999999)
	yield(get_tree().create_timer(0.05), "timeout") #Close Game delay
	global_map.GLOBAL_p_hit = false
	


