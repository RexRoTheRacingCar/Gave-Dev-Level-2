extends Node2D

onready var rope = get_node("ropeConnect")

export onready var pointHolder = self.get_node("base/rigid")
var pointPos
var point = Vector2()

var onScreen := false

func _ready():
	pointPos = pointHolder.get_children()
	
	scale = Vector2(rand_range(2.0, 4.0), rand_range(3.0, 7.0))
	
	
	for id in pointPos.size(): 
		rope.add_point(Vector2(0, 0), 0)
		
		var scaler = pointPos[id].get_children()
		scaler[0].scale = scale * 1.25

func _physics_process(_delta):
	if onScreen == true: connect_line()


func connect_line():
	for i in pointPos.size(): 
		var ropePoint = pointPos[i].position
		
		rope.global_rotation = 0
		
		
		rope.set_point_position(i, ropePoint)


func _on_vis_screen_entered():
	onScreen = true
	visible = true

func _on_vis_screen_exited():
	onScreen = false
	visible = false
