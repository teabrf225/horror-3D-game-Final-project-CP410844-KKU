extends RigidBody3D

@export var text_key: String = ""
@export var text_mesh: MeshInstance3D

func _ready() -> void:
	if text_mesh and text_mesh.mesh is TextMesh:
		# ทำสำเนา Mesh แยกเฉพาะตัวนี้
		var unique_mesh = text_mesh.mesh.duplicate()
		unique_mesh.text = text_key
		text_mesh.mesh = unique_mesh
