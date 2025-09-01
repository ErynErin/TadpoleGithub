extends Area2D
class_name InteractionArea
@export var action_name: String = "interact"
@export var y_position = 45.0

var interact: Callable = func():
	pass

func _on_body_entered(body: Node2D) -> void:
	# Check if the body that entered is in the "player" group.
	# If it's not the player, the function will exit here.
	if not body.is_in_group("player"):
		return
		
	# If the body is the player, register the area with the InteractionManager.
	InteractionManager.register_area(self)

func _on_body_exited(body: Node2D) -> void:
	# Check if the body that exited is in the "player" group.
	if not body.is_in_group("player"):
		return
	
	# If the body is the player, unregister the area.
	InteractionManager.unregister_area(self)
