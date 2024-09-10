extends Node2D

var ex_rad = preload("res://Other/Explode_1_Radius.tres")

func _ready(): #Enable exploding particle effects, apply shake
	$Bubbles.emitting = true
	$Explode.emitting = true
	$Flash_1.visible = true
	$Flash_2.visible = true
	
	if global_map.opt_mode == true: 
		$Bubbles.amount = 20
		$Explode.amount = 120
	else:
		$Bubbles.amount = 10
		$Explode.amount = 75
	
	ex_rad.radius = 32.5 + (7.5 * global_map.diff_mode)
	
	global_map.GLOBAL_screen_shake = 250

func _on_Timer_timeout(): #Delete Explosion
	queue_free()

func _on_Timer_b_timeout(): #Disable Explosion Collision
	$Explode_Holder/Explode_Shape.disabled = true
	$Explode_Holder2/Explode_Shape2.disabled = true
	$Flash_1.visible = false
	$Flash_2.visible = false

func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	$Bubbles.emitting = false
	$Explode.emitting = false

