extends CanvasLayer

#Fade animation for intro
onready var animation := $AnimationPlayer

func _ready(): 
	visible = true
	$ColorRect.self_modulate = Color(1, 1, 1, 1)
	
	animation.play("fade")
