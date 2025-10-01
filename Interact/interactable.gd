extends CollisionObject3D
class_name Interactable

signal interacted(body)

@export var interact_text = "Interact"
@export var interact_input = "interact"

func get_interact_input():
	var key_name = ""
	for action in InputMap.action_get_events(interact_input):
		key_name = action.as_text()
	
	return interact_text + "\n[" + key_name.split(" ")[0] + "]"		 

func interact(body):
	print(body.name," interact ",owner.name)
	interacted.emit(body)
