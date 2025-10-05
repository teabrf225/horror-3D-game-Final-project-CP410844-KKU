extends Node3D

@onready var rng = RandomNumberGenerator.new()

func enter_trigger(body):
	if body.name == "ghots" and body.destination == self:
		print("enter destination")
		@warning_ignore("redundant_await")
		body.state_idle()
		await get_tree().create_timer(rng.randf_range(1.0,7.0), false).timeout.connect(_new_destination.bind(body))

func _new_destination(body):
	print("time out")
	body.pick_destination(body.destination_value)
