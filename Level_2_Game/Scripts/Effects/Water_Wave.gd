extends StaticBody2D


func _ready(): #Prep surfaces on the map
	$Sine_Water1.motion_speed = 0.75
	$Sine_Water1.motion_height = 12.5
	$Sine_Water1.wave_increments = 25
	$Sine_Water1.wave_pos_offset = 1000
	
	$Sine_Water2.motion_speed = -0.65
	$Sine_Water2.motion_height = -10
	$Sine_Water2.wave_increments = -35
	$Sine_Water2.wave_pos_offset = (200 * -35) + 1000

func _on_Vis_viewport_entered(_viewport): visible = true
func _on_Vis_viewport_exited(_viewport): visible = false
