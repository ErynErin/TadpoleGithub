extends Control

@onready var music_slider = $ColorRect/VBoxContainer/Music_Slider
@onready var sfx_slider = $ColorRect/VBoxContainer/SFX_Slider

@export var music_bus_name: String = "Music"
@export var sfx_bus_name: String = "SFX"

var music_bus_index
var sfx_bus_index

func _ready():
	music_bus_index = AudioServer.get_bus_index(music_bus_name)
	sfx_bus_index = AudioServer.get_bus_index(sfx_bus_name)

	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus_index))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_index))

	music_slider.value_changed.connect(_on_music_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)

func _on_music_slider_value_changed(value: float):
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value))

func _on_sfx_slider_value_changed(value: float):
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(value))

func _on_exit_pressed() -> void:
	GameManager.hide_options()
