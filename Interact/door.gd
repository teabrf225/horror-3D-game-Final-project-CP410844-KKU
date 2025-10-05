extends Interactable

var open = false

# ประเภทของประตู: "normal" หรือ "code"
@export var door_type: String = "normal"

# สำหรับ animation
@export var animation_play: AnimationPlayer

# สำหรับเสียง
@export var open_sound: AudioStream
@export var close_sound: AudioStream
@export var jump_scare_sound: AudioStream
# รหัสสำหรับเปิดประตู (ถ้าเป็น code door)
@export var door_code: String = "1234"

# NodePath ของ UI เพื่อเรียกเปิดหน้าต่างรหัส
@export var ingame_ui: NodePath


func _ready():
	interacted.connect(_on_interacted)

func _on_interacted(_body):
	if animation_play.current_animation in ["open", "close"]:
		return # กำลังเล่น animation อยู่, หยุดไม่ให้ trigger ซ้ำ

	if door_type == "normal":
		_toggle_door()
	elif door_type == "code" and !open:
		if ingame_ui:
			var ui_node = get_node(ingame_ui)
			ui_node.open_password_exit_door(self) # ส่ง reference ของประตูให้ UI
	elif door_type == "fake":
		animation_play.play("jump_scare")
		AudioManager.play_sfx(jump_scare_sound)
		get_tree().create_timer(0.6).timeout.connect(queue_door)
	
func queue_door():	
	get_parent().get_parent().get_parent().get_parent().queue_free()
# --- ฟังก์ชันเปิด/ปิดประตู ---
func _toggle_door():
	open = !open
	if open:
		print("Door opened")
		if open_sound:
			AudioManager.play_sfx(open_sound)
		animation_play.play("open")
	else:
		print("Door closed")
		if close_sound:
			AudioManager.play_sfx(close_sound)
		animation_play.play("close")
