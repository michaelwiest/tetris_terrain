extends Node2D

class_name Upgrade
enum Timing {BEFORE_MATCH, AFTER_MATCH}
@onready var active: bool = true
@export var color: Color = Color(1, 1, 1)
@export var display_name: String
@export_multiline var description: String
@export var is_permanent: bool = false
@export var timing: Timing
@onready var icon = $Icon

func hide_icon():
	icon.hide()

# Called when the node enters the scene tree for the first time.
func _ready():
#	icon.visible = false
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func trigger(tilemap: TileMap, recipe: Recipe):
	if active:
		trigger_internal(tilemap, recipe)
	
func trigger_internal(tilemap: TileMap, recipe: Recipe):
	pass

