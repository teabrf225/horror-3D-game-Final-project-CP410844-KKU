extends Node3D

@onready var end_scene_animation_player: AnimationPlayer = $End_scene_AnimationPlayer
@export var list_background_music: Array[AudioStream]
@onready var player_camera_3d: Camera3D = $Player/Head/Camera3D
@onready var ghot_camera_3d: Camera3D = $ghots/Camera3D
@onready var ghot_animation_player: AnimationPlayer = $ghots/AnimationPlayer
@export var jumpscare_sfx: AudioStream = null
@onready var player: CharacterBody3D = $Player
@onready var show_text: Control = $Show_text
@export var run_sfx_scene: AudioStream
@onready var ghot_camera_3d2: Camera3D = $ghots2/Camera3D
@onready var ghot_animation_player2: AnimationPlayer = $ghots2/AnimationPlayer

func _ready() -> void:
	if list_background_music.size() > 0:
		AudioManager.play_bgm_list(list_background_music, true)  # true = วน playlist
	show_text.show_text_hide()

func _on_player_entered_exit_zore(body: Node3D) -> void:
	if body.is_in_group("Player"):
		pass


func _on_ghots_dead_now() -> void:
	player_camera_3d.current = false
	ghot_camera_3d.current = true
	dead()

func dead():
	print("dead")
	AudioManager.play_sfx(jumpscare_sfx)
	ghot_animation_player.play("jumpscare")
	await  ghot_animation_player.animation_finished
	player.queue_free()
	get_tree().change_scene_to_file("res://GUI/dead_scene.tscn")


func _on_area_player_entered_exit_door(body: Node3D) -> void:
	if body.name == "Player":
		player.max_stamina = 300
		player.stamina = 300
		AudioManager.play_sfx(run_sfx_scene)
		show_text.show_text_run()
		end_scene_animation_player.play("end_scene")

func dead2():
	print("dead")
	AudioManager.play_sfx(jumpscare_sfx)
	ghot_animation_player2.play("jumpscare")
	await  ghot_animation_player2.animation_finished
	player.queue_free()
	get_tree().change_scene_to_file("res://GUI/dead_scene.tscn")

func _on_area_run_player_entered(body: Node3D) -> void:
	if body.name == "Player":
		player_camera_3d.current = false
		ghot_camera_3d2.current = true
		dead2()


func _on_exit_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		print("win")
		player.queue_free()
		AudioManager.stop_bgm()
		get_tree().change_scene_to_file("res://GUI/end_credits.tscn")
