extends Node3D

@onready var animation_player :AnimationPlayer= $AnimationPlayer
@export var list_background_music: Array[AudioStream]

func _ready() -> void:
	if list_background_music.size() > 0:
		AudioManager.play_bgm_list(list_background_music, true)  # true = วน playlist


func _on_player_entered_exit_zore(body: Node3D) -> void:
	if body.is_in_group("Player"):
		animation_player.play("end_level01")
		await animation_player.animation_finished
		get_tree().change_scene_to_file("res://Level/level02.tscn")
