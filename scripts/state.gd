extends Node2D
class_name State

@onready var player = owner.get_parent().find_child("player")
@onready var debug: Label = $"../../Debug"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"  # Causing an error

func _ready():
	set_physics_process(false)

func enter():
	set_physics_process(true)
	
func exit():
	set_physics_process(false)

func transition():
	pass

func _physics_process(_delta: float):
	transition()
	debug.text = name
