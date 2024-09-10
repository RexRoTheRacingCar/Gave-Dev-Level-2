extends Sprite

var scale_time = 0
onready var anim := $AnimationPlayer

func _ready(): anim.play("pulse")

func _on_VisibilityNotifier2D_viewport_exited(_viewport): queue_free() #Delete if off screen
