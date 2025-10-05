extends Node3D

@onready var animation_player :AnimationPlayer= $AnimationPlayer
@export var list_background_music: Array[AudioStream]

func _ready() -> void:
	if list_background_music.size() > 0:
		AudioManager.play_bgm_list(list_background_music, true)  # true = วน playlist


func _on_player_entered_exit_zore(body: Node3D) -> void:
	if body.is_in_group("Player"):
		pass
