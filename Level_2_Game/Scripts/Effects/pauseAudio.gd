extends Node

onready var audioBus = AudioServer.get_bus_index("Master")

func _on_VolSlider_value_changed(value):
	AudioServer.set_bus_volume_db(audioBus, linear2db(value))
	AudioServer.set_bus_mute(audioBus, value < 0.05)
	
	global_map.GLOBAL_audioVolume = value
