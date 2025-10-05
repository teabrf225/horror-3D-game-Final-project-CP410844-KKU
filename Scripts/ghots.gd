extends CharacterBody3D

@export var patrol_destiantion: Array[Node3D]
@onready var player = get_tree().current_scene.get_node("Player")
var speed = 2.0
@onready var rng = RandomNumberGenerator.new()
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $"Breathing Idle/AnimationPlayer"
@onready var animation_player_main: AnimationPlayer = $AnimationPlayer

var destination
var destination_value
var chasing = false
var chasing_time :float = 0.0
var idle = false
var attack = false

@export var chas_sfx: AudioStream
@export var jumpscare_sfx: AudioStream

signal dead_now

func _ready() -> void:
	pick_destination()
	
func  _process(delta: float) -> void:
	if !chasing:
		if speed != 2.0:
			speed = 2.0
	if chasing:
		if speed != 3.0:
			speed = 3.0
		if chasing_time < 10:
			chasing_time += 1 * delta
		else:
			chasing_time = 0
			chasing = false
			pick_destination()
	if destination != null:
		var look_dir = lerp_angle(deg_to_rad(global_rotation_degrees.y),atan2(-velocity.x, -velocity.z),0.5)
		global_rotation_degrees.y = rad_to_deg(look_dir)
		update_target_location()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	chase_player($RayCast3D)
	chase_player($RayCast3D2)
	chase_player($RayCast3D3)
	chase_player($RayCast3D4)
	chase_player($RayCast3D5)

	if destination != null:
		var current_location = global_transform.origin
		var next_location = navigation_agent_3d.get_next_path_position()
		var new_velocity = (next_location - current_location).normalized() * speed
		if navigation_agent_3d.avoidance_enabled:
			navigation_agent_3d.set_velocity(new_velocity)
		else:
			_on_navigation_agent_3d_velocity_computed(new_velocity)
			
func chase_player(chasecast:RayCast3D):
	if chasecast.is_colliding():
		var hit = chasecast.get_collider()
		if hit.name == "Player":
			if !chasing:
				chasing = true
				destination = player

func pick_destination(dont_choose: int = -1) -> void:
	idle = false
	if !chasing:
		if patrol_destiantion.size() == 0:
			destination = null
			destination_value = -1
			return

		var choices := []
		# สร้าง list ของ index ที่เป็นไปได้ (ยกเว้น dont_choose)
		for i in patrol_destiantion.size():
			if i != dont_choose:
				choices.append(i)
		
		# สุ่ม index จาก choices
		var num = rng.randi_range(0, choices.size() - 1)
		destination_value = choices[num]
		destination = patrol_destiantion[destination_value]
		
func state_idle():
	idle = true
	print("idle")
	velocity = Vector3.ZERO
	if animation_player.current_animation != "Idle":
		animation_player.play("Idle")

func update_target_location():
	if destination != null:
		navigation_agent_3d.target_position = destination.global_transform.origin

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if !attack:
		velocity = velocity.move_toward(safe_velocity, 0.25)
		move_and_slide()
		if !idle and !chasing and animation_player.current_animation != "Running_norm":
			animation_player.play("Running_norm")
		if !idle and chasing and animation_player.current_animation != "RunningCrawl":
			animation_player.play("RunningCrawl")


func _on_attack_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		attack = true
		idle = false
		chasing = false
		AudioManager.play_sfx(chas_sfx)
		animation_player.play("jumpOver")
		dead_now.emit()
		await animation_player.animation_finished
		print("attack!!!")
