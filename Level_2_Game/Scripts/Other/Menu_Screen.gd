extends Control

var settings = preload("res://Scenes/Main/Settings_Menu.tscn")

func _ready():
	$CenterContainer/VBoxContainer/Srt_Btn.text = str("Start Game")
	
	var screensize = global_map.GLOBAL_screensize
	
	$Overlay.position = Vector2(screensize.x / 2, screensize.y / 2)
	$BG2.position = Vector2(screensize.x / 2, screensize.y / 2)
	$BG_Menu/Particles2D1.position = Vector2(screensize.x / 2, screensize.y / 2)
	$BG_Menu/Particles2D2.position = Vector2(screensize.x / 2, screensize.y / 2)
	$BG_Menu/Vignette.position = Vector2(screensize.x / 2, screensize.y / 2)

func _on_Start_Game_pressed(): #When start game pressed
	$CenterContainer/VBoxContainer/Srt_Btn.text = str("~ Loading ~")
	AudioEffects.play("res://Audio/uiSound.mp3")
	
	yield(get_tree().create_timer(0.1, false), "timeout") #No-hit delay
	
	var error = get_tree().change_scene("res://Scenes/Main/Test_Map.tscn") #Go to main scene
	global_map.GLOBAL_main_scene = "In_Game"
	
	if error != 0: #Fix scene bug
		queue_free()
	queue_free()

func _on_Set_Btn_pressed(): 
	global_map.menu_open = true
	AudioEffects.play("res://Audio/uiSound.mp3")

func _on_QuitBtn_pressed(): get_tree().quit() #Quit game 
