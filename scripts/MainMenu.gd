extends Node2D
@onready var timer = $Timer
@export_file var level_path
# Called when the node enters the scene tree for the first time.
func _ready():
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file(level_path)
		


func _on_timer_timeout():
	get_tree().change_scene_to_file(level_path)
