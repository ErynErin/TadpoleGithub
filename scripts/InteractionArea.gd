extends Area2D
class_name InteractionArea
@export var action_name: String = "interact"
@export var y_position = 45.0

var interact: Callable = func():
	pass

func _on_body_entered(_body: Node2D) -> void:
	InteractionManager.register_area(self)

func _on_body_exited(_body: Node2D) -> void:
	InteractionManager.unregister_area(self)
