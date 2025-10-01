extends Interactable

var open = false

@export var box_animation_name :String = ""
@export var animation_play :AnimationPlayer
@export var sound_effect: AudioStream

func _ready():
	interacted.connect(_on_interacted)

func _on_interacted(_body):
	if animation_play.current_animation != "Open_"+box_animation_name and animation_play.current_animation != "Close_"+box_animation_name:
		open = !open
		if open:
			print("open")
			AudioManager.play_sfx(sound_effect)
			animation_play.play("Open_"+box_animation_name)
		if !open:
			print("close")
			AudioManager.play_sfx(sound_effect)
			animation_play.play("Close_"+box_animation_name)
