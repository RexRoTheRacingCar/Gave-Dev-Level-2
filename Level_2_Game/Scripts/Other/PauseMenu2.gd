extends Control

var is_paused = false setget set_is_paused

func _ready(): #Prepare pause menu
	visible = is_paused
	
	$CenterContainer/VBoxContainer/VolSlider.value = global_map.GLOBAL_audioVolume

func _unhandled_input(event): #Change pause status based on "pause" pressed
	if event.is_action_pressed("pause") && global_map.GLOBAL_game_end == false:
		self.is_paused = !is_paused

func set_is_paused(value): #Change game pause status
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused
	

func _on_ResumeBtn_pressed(): #Change game pause status when resume pressed
	self.is_paused = false
	AudioEffects.play("res://Audio/uiSound.mp3")
	
func _on_RestartBtn_pressed():
	self.is_paused = false
	global_map.GLOBAL_p_hp = 0
	AudioEffects.play("res://Audio/uiSound.mp3")
	
func _on_QuitBtn_pressed(): get_tree().quit() #Quit game 

