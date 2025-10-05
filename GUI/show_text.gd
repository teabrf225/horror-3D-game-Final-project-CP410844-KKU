extends Control

@onready var hide_color_background: ColorRect = $CanvasLayer/hide_color_background
@onready var run_color_background: ColorRect = $CanvasLayer/run_color_background
@onready var hide: Label = $CanvasLayer/hide
@onready var run: Label = $CanvasLayer/run

func _ready() -> void:
	hide_color_background.visible = false
	run_color_background.visible = false
	hide.visible = false
	run.visible = false
	
func show_text_hide():
	hide_color_background.visible = true
	hide.visible = true
	await get_tree().create_timer(5).timeout
	hide_color_background.visible = false
	hide.visible = false

func show_text_run():
	run_color_background.visible = true
	run.visible = true
	await  get_tree().create_timer(10).timeout
	run.visible = false
