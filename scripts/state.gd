extends Node2D
class_name State

@onready var debug = owner.find_child("debug")
@onready var animation_player = owner.find_child("AnimationPlayer")
@onready var player =  owner.get_parent().find_child("player")

func _ready() -> void:
	set

func transition():
	pass

func _physics_process(_delta: float) -> void:
	transition()
	debug.text = name
