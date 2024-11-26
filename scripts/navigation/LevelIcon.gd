extends Control

class_name LevelIcon

@export_file var level_path: String
var level: Level
# Called when the node enters the scene tree for the first time.
func _ready():
	level = load(level_path).instantiate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
