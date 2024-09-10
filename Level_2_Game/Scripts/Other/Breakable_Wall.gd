extends KinematicBody2D

onready var anim := $AnimationPlayer

func _ready():
	$Sprite.modulate = Color(1.5, 1.5, 1.5) 

func _on_Wall_Hitbox_body_entered(body): #Delete wall if explosion nearby
	if "Explode_Holder2" in body.name or "Explode_Shape2" in body.name: _kill()
	else: pass
	
func _kill(): queue_free()

#Hide if not on screen. 
func _on_Visibilty_Box_viewport_entered(_viewport): visible = true
func _on_Visibilty_Box_viewport_exited(_viewport): visible = false
