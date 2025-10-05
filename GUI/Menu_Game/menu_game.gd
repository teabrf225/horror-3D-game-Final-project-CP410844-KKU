extends Control

@onready var Main_buttons: VBoxContainer = $Main_buttons
@onready var Options: Panel = $Options
@onready var Credits: Panel = $Credits

func _ready() -> void:
	Main_buttons.visible = true
	Options.visible = false
	Credits.visible = false
	
#func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("test_world") and Global.debug_mode:
		#SceneTransitions.transition()
		#await SceneTransitions.on_animation_finished
		#var loading_scene = load("res://World/Test/world_test.tscn")
		#get_tree().change_scene_to_packed(loading_scene)
#
func _on_start_pressed() -> void:
	#SceneTransitions.transition()
	#await SceneTransitions.on_animation_finished
	#get_tree().change_scene_to_file("res://World/Forest_day/forest_day.tscn")
	var loading_scene = load("res://Level/level01.tscn")
	get_tree().change_scene_to_packed(loading_scene)

func _on_option_pressed() -> void:
	Options.visible = true

func _on_credit_pressed() -> void:
	Credits.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_back_options_pressed() -> void:
	_ready()
