extends Area2D

var boomfish = preload("res://Scenes/Enemy/Barracuda.tscn")

var text1 = preload("res://Assets/Enviroment/treasure2.tres")
var text2 = preload("res://Assets/Enviroment/treasure1.tres")

var opened := false

func _ready(): 
	$Sprite.texture = text1
	$BreathParticles2D.emitting = false
	opened = false

func _on_treasure_body_entered(body):
	if "Player" in body.name && opened == false:
		opened = true

		$Sprite.texture = text2
		$BreathParticles2D.emitting = true
		
		AudioEffects.play("res://Audio/chestOpen.mp3")
		
		$waitTimer.start(0.8)


func _on_waitTimer_timeout():
	global_map.GLOBAL_game_end = true
	AudioEffects.play("res://Audio/shockChest.mp3")
