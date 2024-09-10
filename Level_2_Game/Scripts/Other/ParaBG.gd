extends ParallaxBackground

onready var paraF := get_node("ParallaxF/folder").get_children()
onready var paraM := get_node("ParallaxM/folder").get_children()
onready var paraB := get_node("ParallaxB/folder").get_children()

func _ready():
	for i in paraF: i.global_position *= Vector2(0.8, 0.8)
	for i in paraM: i.global_position *= Vector2(0.6, 0.6)
	for i in paraB: i.global_position *= Vector2(0.4, 0.4)
