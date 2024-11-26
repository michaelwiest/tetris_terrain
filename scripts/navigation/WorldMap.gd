extends Control

@onready var level_parent: Control = $LevelHolder
@onready var level_icons: Array[LevelIcon] = []
@onready var level_highlight: Sprite2D = $Control/LevelHighlight
@onready var camera_holder: Control = $Control

var selected_level_index: int = 0
var size_tween
# First level is always playable
var level_availables: Array[bool] = [true]
var levels: Array[Level] = []

var _save: SaveGame
@onready var active_level_title_node: Label = $Control/Camera2D/CanvasLayer/LevelInfoBanner/Panel/MarginContainer/VBoxContainer/Title
@onready var active_level_description_node: Label = $Control/Camera2D/CanvasLayer/LevelInfoBanner/Panel/MarginContainer/VBoxContainer/Description
@onready var play_prompt: Label = $Control/Camera2D/CanvasLayer/PlayPrompt

func _load_data():
	SaveGame.load_all_data()
	for li in level_icons:
		levels.append(li.level)
	for i in range(len(level_icons) - 1):
		var l: Level = level_icons[i].level
		if _save._has_level_data(l.level_id):
			level_availables.append(SaveGame._load_level_data(l.level_id).completed)
		else:
			level_availables.append(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	size_tween = create_tween()
	for l in level_parent.get_children():
		if l is LevelIcon:
			level_icons.append(l)
	camera_holder.position = level_icons[selected_level_index].position - Vector2(32, 32)

	size_tween.set_trans(Tween.TRANS_ELASTIC)
	size_tween.set_loops()
	size_tween.tween_property(level_highlight, "scale", Vector2(1.2, 1.2), 0.5)
	size_tween.set_ease(Tween.EASE_OUT)
	size_tween.tween_property(level_highlight, "scale", Vector2(1, 1), 0.5)
	size_tween.set_ease(Tween.EASE_IN)
	
	_save = SaveGame.new()
	_load_data()
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	camera_holder.position = level_icons[selected_level_index].position - Vector2(32, 32)
	if Input.is_action_just_pressed("ui_right"):
		selected_level_index += 1
	elif Input.is_action_just_pressed("ui_left"):
		selected_level_index -= 1
		if selected_level_index < 0:
			selected_level_index = len(level_icons) - 1
	if Input.is_action_just_pressed("ui_accept"):
		if level_availables[selected_level_index]:
			get_tree().change_scene_to_file(level_icons[selected_level_index].level_path)
		else:
			print("cannot play current level")
	
	
	selected_level_index = selected_level_index % len(level_icons)
	var selected_level = levels[selected_level_index]
	active_level_description_node.text = selected_level.description
	active_level_title_node.text = selected_level.level_name
	
	# Toggle the opacity depending on if it is playable
	if not level_availables[selected_level_index]:
		active_level_description_node.modulate.a = 0.2
		active_level_title_node.modulate.a = 0.2
		play_prompt.hide()
	if level_availables[selected_level_index]:
		active_level_description_node.modulate.a = 1
		active_level_title_node.modulate.a = 1
		play_prompt.show()
	
