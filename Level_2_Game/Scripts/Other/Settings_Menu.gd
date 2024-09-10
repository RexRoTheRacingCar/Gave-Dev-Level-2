extends Control

func _ready(): #Prep settings menu display
	visible = false
	$CenterContainer/VBoxContainer/Opt_Box.pressed = global_map.opt_mode
	$CenterContainer/VBoxContainer/Shake_Box.pressed = global_map.shake_mode
	$CenterContainer/VBoxContainer/Glow_Box.pressed = global_map.bloom_mode
	
	$CenterContainer/VBoxContainer/Diff_Slider.value = global_map.diff_mode
	
func _process(_delta): 
	if global_map.menu_open == true: visible = true

func _on_Quit_Btn_pressed(): #Close settings menu
	global_map.menu_open = !global_map.menu_open
	visible = !visible
	AudioEffects.play("res://Audio/uiSound.mp3")

func _unhandled_input(event): #Change pause status based on "pause" pressed
	if event.is_action_pressed("pause"): _on_Quit_Btn_pressed()

#Graphics Settings
func _on_Opt_Box_toggled(button_pressed): 
	global_map.opt_mode = button_pressed
	AudioEffects.play("res://Audio/uiSound.mp3")
func _on_Shake_Box_toggled(button_pressed): 
	global_map.shake_mode = button_pressed
	AudioEffects.play("res://Audio/uiSound.mp3")
func _on_Glow_Box_toggled(button_pressed): 
	global_map.bloom_mode = button_pressed
	AudioEffects.play("res://Audio/uiSound.mp3")

#Gameplay Settings
func _on_Diff_Slider_value_changed(value): 
	global_map.diff_mode = value
	AudioEffects.play("res://Audio/uiSound.mp3")





