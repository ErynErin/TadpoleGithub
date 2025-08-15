extends State

@onready var collision: CollisionShape2D = $"../../Player Detector/CollisionShape2D"
@onready var progress_bar: ProgressBar = $"../../CanvasLayer/ProgressBar"

var player_entered: bool = false:
	set(value):
		player_entered = value
		collision.set_deferred("disabled", value)
		progress_bar.set_deferred("visible", value)

func _on_player_detector_body_entered(_body: Node2D):
	player_entered = true

func transition():
	if player_entered:
		get_parent().change_state("follow")
