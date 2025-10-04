extends Control

# --- ตัวแปรใหม่สำหรับประตู ---
var current_door: Node = null
@onready var Options: Panel = $Options

func _ready() -> void:
	Options.visible = false
	$pause_menu.visible = false
	$task_exit_door_ui.visible = false

	# เชื่อมสัญญาณ LineEdit ของรหัส
	if not $task_exit_door_ui/LineEdit.is_connected("text_submitted", Callable(self, "_on_code_submitted")):
		$task_exit_door_ui/LineEdit.connect("text_submitted", Callable(self, "_on_code_submitted"))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and !$task_exit_door_ui.visible:
		$pause_menu.visible = !$pause_menu.visible
		get_tree().paused = $pause_menu.visible
		if get_tree().paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if !get_tree().paused:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# --- ฟังก์ชันเกี่ยวกับประตู ---
func open_password_exit_door(door: Node):
	$task_exit_door_ui.visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	current_door = door
	$task_exit_door_ui/LineEdit.text = ""  # ล้างข้อความเก่า

func exit_password_exit_door():
	$task_exit_door_ui.visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	current_door = null

func confirm_password_exit_door():
	_on_code_submitted($task_exit_door_ui/LineEdit.text)

# เรียกเมื่อผู้เล่นกด Enter หรือส่ง LineEdit
func _on_code_submitted(input_code: String):
	print(input_code)
	if current_door == null:
		return

	if input_code == current_door.door_code:
		current_door._toggle_door()  # เปิดประตู
		exit_password_exit_door()
	else:
		print("Wrong code!")
		#AudioManager.play_sfx(load("res://sounds/error.ogg"))

# --- ฟังก์ชันอื่นที่ไม่เกี่ยวกับประตู (คงไว้เหมือนเดิม) ---
func resume_game():
	get_tree().paused = false
	$pause_menu.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func quit_game():
	get_tree().quit()


func _on_setting_pressed() -> void:
	Options.visible = !Options.visible


func _on_back_pressed() -> void:
	Options.visible = !Options.visible
