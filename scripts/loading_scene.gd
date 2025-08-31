extends Control

var next_scene = GameManager.next_scene_path

func _ready() -> void:
	next_scene = GameManager.next_scene_path
	
	if next_scene.is_empty():
		return
	
	ResourceLoader.load_threaded_request(next_scene)

func _process(_delta: float) -> void:
	var progress = []
	ResourceLoader.load_threaded_get_status(next_scene, progress)
	$progress_bar.value = progress[0]*100
	$progress_num.text = str(round(progress[0]*100))+"%"
	
	if progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get(next_scene)
		get_tree().change_scene_to_packed.call_deferred(packed_scene)
