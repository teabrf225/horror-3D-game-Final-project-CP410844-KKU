extends CharacterBody3D

# --- movement ---
var SPEED = 1.0
var SPRINT_SPEED = 4.5
var crouch_speed = 0.4
const JUMP_VELOCITY = 3.5
var CameraSensitivity = 0.05

# --- camera/flashlight motion ---
var yaw_input := 0.0
var pitch_input := 0.0
var flashlight_yaw := 0.0
var flashlight_pitch := 0.0
var head_yaw := 0.0
var camera_pitch := 0.0
var crouching = false

var flashlight_speed := 10.0   # ความเร็วไฟฉาย
var head_follow_speed := 3  # ความเร็วหัว/กล้องตามไฟฉาย

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var flashlight = $Head/Camera3D/Flashlight

# --- sound effect ---
@onready var footstep_player = $FootstepPlayer
@onready var heartbeat_player = $HeartbeatPlayer
@onready var flashlight_player = $FlashlightPlayer
@export var footstep_walk_sound: AudioStream
@export var footstep_run_sound: AudioStream
@export var heartbeat_sound: AudioStream
@export var flashlight_sound: AudioStream

# --- stamina system ---
var max_stamina := 100.0
var stamina := 100.0
var sprint_drain_rate := 15.0
var sprint_regen_rate := 5.0

# --- refs ---
var ORIGINAL_SPEED: float
var sprint_slider: Slider
var fade_tween: Tween

# --- colors ---
var color_full := Color(1, 1, 1)          
var color_mid := Color(1, 1, 0.6)         
var color_low := Color(1, 0.2, 0.2)       

# --- fade control ---
var fade_delay := 0.5
var fade_timer := 0.0

func _ready():
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	ORIGINAL_SPEED = SPEED
	
	# stamina bar
	sprint_slider = get_node("/root/" + get_tree().current_scene.name + "/UI_Ingame/Sprint_Slider")
	sprint_slider.min_value = 0.0
	sprint_slider.max_value = 1.0
	sprint_slider.value = 1.0
	sprint_slider.modulate.a = 0.0
	
	#flashlight
	flashlight_player.stream = flashlight_sound
	
	# heartbeat
	if heartbeat_sound:
		heartbeat_sound.loop = true
	heartbeat_player.stream = heartbeat_sound
	heartbeat_player.volume_db = -30
	heartbeat_player.play()

func _input(event: InputEvent) -> void:
	if (Input.mouse_mode != Input.MOUSE_MODE_CAPTURED) and event is InputEventMouseButton: 
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion:
		yaw_input -= event.relative.x * CameraSensitivity
		pitch_input -= event.relative.y * CameraSensitivity
		pitch_input = clamp(pitch_input, -50, 50)

	if Input.is_action_just_pressed("flashlight"):
		flashlight_player.play()
		flashlight.visible = !flashlight.visible

	if Input.is_action_just_pressed("crouch"):
		crouching = !crouching

func _process(delta: float) -> void:
	# --- Flashlight lead ---
	flashlight_yaw = lerp(flashlight_yaw, yaw_input, flashlight_speed * delta)
	flashlight_pitch = lerp(flashlight_pitch, pitch_input, flashlight_speed * delta)

	# จำกัด flashlight yaw ให้ห่างจาก head ไม่เกิน 90°
	flashlight_yaw = clamp(flashlight_yaw, head_yaw - 90, head_yaw + 90)

	# --- Head/Camera lag ---
	head_yaw = lerp(head_yaw, flashlight_yaw, head_follow_speed * delta)
	camera_pitch = lerp(camera_pitch, flashlight_pitch, head_follow_speed * delta)

	rotation.y = deg_to_rad(head_yaw)
	camera.rotation.x = deg_to_rad(camera_pitch)

	# --- Flashlight offset ---
	flashlight.rotation.y = deg_to_rad(flashlight_yaw - head_yaw)
	flashlight.rotation.x = deg_to_rad(flashlight_pitch - camera_pitch)

	# --- stamina logic ---
	if SPEED == SPRINT_SPEED:
		stamina = max(stamina - sprint_drain_rate * delta, 0)
		if stamina <= 0:
			SPEED = ORIGINAL_SPEED
	else:
		stamina = min(stamina + sprint_regen_rate * delta, max_stamina)

	var stamina_ratio = stamina / max_stamina
	sprint_slider.value = stamina_ratio

	if stamina < max_stamina or SPEED == SPRINT_SPEED:
		_show_stamina_bar()
		fade_timer = 0.0
	else:
		fade_timer += delta
		if fade_timer >= fade_delay:
			_hide_stamina_bar()

	# สี stamina bar
	var new_color: Color
	if stamina_ratio > 0.5:
		var t = (1.0 - stamina_ratio) * 2.0
		new_color = color_full.lerp(color_mid, t)
	else:
		var t = (0.5 - stamina_ratio) * 2.0
		new_color = color_mid.lerp(color_low, t)

	sprint_slider.modulate.r = new_color.r
	sprint_slider.modulate.g = new_color.g
	sprint_slider.modulate.b = new_color.b
	
	# heartbeat effect
	heartbeat_player.volume_db = lerp(-35, 80, 1.0 - stamina_ratio)
	heartbeat_player.pitch_scale = lerp(1.0, 2.0, 1.0 - stamina_ratio)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# crouch
	if crouching and $CollisionShape3D.shape.height > 0.1:
		var crouch_height = lerp($CollisionShape3D.shape.height, 0.1, 0.2)
		$CollisionShape3D.shape.height = crouch_height
		SPEED = crouch_speed
	if not crouching and $CollisionShape3D.shape.height < 1.074 and not Input.is_action_pressed("sprint"):
		var crouch_height = lerp($CollisionShape3D.shape.height, 1.074, 0.2)
		$CollisionShape3D.shape.height = crouch_height
		SPEED = ORIGINAL_SPEED

	# jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# movement
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		if Input.is_action_pressed("sprint") and stamina > 0 and not crouching:
			SPEED = SPRINT_SPEED
			_show_stamina_bar()
			fade_timer = 0.0

			# เสียงวิ่ง
			if footstep_player.stream != footstep_run_sound:
				footstep_player.stream = footstep_run_sound
			if not footstep_player.playing:
				footstep_player.play()
		else:
			SPEED = ORIGINAL_SPEED

			# เสียงเดิน
			if footstep_player.stream != footstep_walk_sound:
				footstep_player.stream = footstep_walk_sound
			if not footstep_player.playing:
				footstep_player.play()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

		# หยุดเสียงทันที
		if footstep_player.playing:
			footstep_player.stop()

	move_and_slide()

# --- stamina bar fade helpers ---
func _show_stamina_bar():
	if sprint_slider.modulate.a < 1.0:
		_start_fade(1.0)

func _hide_stamina_bar():
	if sprint_slider.modulate.a > 0.0:
		_start_fade(0.0)

func _start_fade(target_alpha: float, duration: float = 0.5):
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(sprint_slider, "modulate:a", target_alpha, duration)
