extends HSlider


var audio_bus_id 

func _ready():
	audio_bus_id = AudioServer.get_bus_index("Master")

func _on_value_changed(new_value: float) -> void:
	var db = linear_to_db(new_value)
	AudioServer.set_bus_volume_db(audio_bus_id, db)
