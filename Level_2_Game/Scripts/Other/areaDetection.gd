extends Node

export onready var para = get_node("ParaBG")
export onready var fore = get_node("CanvasFG")

func _ready(): 
	para.visible = false
	fore.visible = false

func _on_vis2D_screen_entered(): 
	para.visible = true
	fore.visible = true

func _on_vis2D_screen_exited(): 
	para.visible = false
	fore.visible = false
