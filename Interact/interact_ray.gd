extends RayCast3D

@onready var interact_text = $Interact_Label

func _physics_process(_delta: float) -> void:
	interact_text.text = ""
	if is_colliding():
		var collider = get_collider()
		if collider is Interactable:
			interact_text.text = collider.get_interact_input()
	
			if Input.is_action_just_pressed(collider.interact_input):
				collider.interact(owner)
