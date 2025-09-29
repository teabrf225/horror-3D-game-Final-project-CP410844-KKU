#extends Node3D
#
#var sens = 0.005
#@onready var cam = $Camera3D
#
#func _ready() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
#
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		## หมุนแกน Y ของ parent (หันซ้าย-ขวา)
		#get_parent().rotate_y(-event.relative.x * sens)
#
		## หมุนแกน X ของกล้อง (ก้ม-เงย)
		#cam.rotate_x(-event.relative.y * sens)
#
		## จำกัดองศากล้องระหว่าง -90 ถึง 90
		#cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-50), deg_to_rad(50))
#
		## เก็บค่า rotation.x ของกล้อง (radian)
		##var cam_rot_x = cam.rotation.x
		## หรือถ้าอยากเป็นองศา
		##var cam_rot_deg = rad_to_deg(cam.rotation.x)
#
		## debug
		##print("Cam X (rad): ", cam_rot_x, " | Cam X (deg): ", cam_rot_deg)
