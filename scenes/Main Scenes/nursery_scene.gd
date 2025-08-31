extends Node2D

@onready var screen_fade = $CanvasLayer/ScreenFade
	

func _ready():
	screen_fade.color.a = 1.0
	screen_fade.set_z_index(1000)
	await fade_out_screen()
	
func fade_in_screen():
	var tween = create_tween()
	tween.tween_property(screen_fade, "color:a", 1.0, 1.5)
	await tween.finished

func fade_out_screen():
	var tween = create_tween()
	tween.tween_property(screen_fade, "color:a", 0.0, 1.5)
	await tween.finished
