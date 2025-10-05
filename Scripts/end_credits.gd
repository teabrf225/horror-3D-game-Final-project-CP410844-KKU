extends Node2D

func _on_video_stream_player_finished() -> void:
	get_tree().quit()
