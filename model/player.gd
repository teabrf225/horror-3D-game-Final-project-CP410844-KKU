extends CharacterBody3D

var SPEED = 1.5
var SPRINT_SPEED = 4.5
const JUMP_VELOCITY = 3.5

# stamina system
var max_stamina := 100.0
var stamina := 100.0
var sprint_drain_rate := 15.0    # ลด 20 ต่อวินาที
var sprint_regen_rate := 5.0    # ฟื้น 10 ต่อวินาที

# refs
var ORIGINAL_SPEED: float
var sprint_slider: Slider
var fade_tween: Tween

# colors
var color_full := Color(1, 1, 1)          # ขาว
var color_mid := Color(1, 1, 0.6)         # เหลืองจาง
var color_low := Color(1, 0.2, 0.2)       # แดง

# fade control
var fade_delay := 0.5   # รอก่อน fade out (วินาที)
var fade_timer := 0.0

func _ready():
	ORIGINAL_SPEED = SPEED
	sprint_slider = get_node("/root/" + get_tree().current_scene.name + "/UI_Ingame/Sprint_Slider")
	sprint_slider.min_value = 0.0
	sprint_slider.max_value = 1.0
	sprint_slider.value = 1.0
	sprint_slider.modulate.a = 0.0   # เริ่มโปร่งใส

func _process(delta: float) -> void:
	# stamina logic
	if SPEED == SPRINT_SPEED:
		stamina = max(stamina - sprint_drain_rate * delta, 0)
		if stamina <= 0:
			SPEED = ORIGINAL_SPEED
	else:
		stamina = min(stamina + sprint_regen_rate * delta, max_stamina)

	# update slider value
	var stamina_ratio = stamina / max_stamina
	sprint_slider.value = stamina_ratio

	# fade in/out with delay
	if stamina < max_stamina or SPEED == SPRINT_SPEED:
		_show_stamina_bar()
		fade_timer = 0.0   # reset timer เมื่อมีการใช้งาน stamina
	else:
		# stamina เต็ม → เริ่มนับเวลา
		fade_timer += delta
		if fade_timer >= fade_delay:
			_hide_stamina_bar()

	# update color (interpolation เฉพาะ RGB)
	var new_color: Color
	if stamina_ratio > 0.5:
		var t = (1.0 - stamina_ratio) * 2.0   # 0..0.5 → 0..1
		new_color = color_full.lerp(color_mid, t)
	else:
		var t = (0.5 - stamina_ratio) * 2.0   # 0.5..0 → 0..1
		new_color = color_mid.lerp(color_low, t)

	# เซ็ตเฉพาะสี ไม่แตะ alpha
	sprint_slider.modulate.r = new_color.r
	sprint_slider.modulate.g = new_color.g
	sprint_slider.modulate.b = new_color.b

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		if Input.is_action_pressed("sprint") and stamina > 0:
			SPEED = SPRINT_SPEED
			_show_stamina_bar()
			fade_timer = 0.0
		else:
			SPEED = ORIGINAL_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

# ----------------------------------
# helper: fade in/out stamina bar
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
