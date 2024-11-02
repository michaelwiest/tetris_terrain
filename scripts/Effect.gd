extends Node2D

class_name Effect

enum Type {BOARD_ALTER, MATCH_ALTER, UPGRADE}
@onready var active: bool = false
@export var location: Vector2i = Vector2i(-1, -1)
var global_location: Vector2i = Vector2i(-1, -1)
@export var type: Type = Type.MATCH_ALTER
@onready var border_animation = $BorderAnimation
@export var color: Color = Color(1, 1, 1)
@export var display_name: String
@export_multiline var description: String
@onready var sfx = $SFX
@onready var icon = $Icon

var is_upgrade = false

# Called when the node enters the scene tree for the first time.
func _ready():
	border_animation.modulate = color
	icon.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _after_trigger():
	pass

func trigger(tilemap: TileMap):
	if active:
		trigger_internal(tilemap)
		sfx.play()
		active = false
	border_animation.visible = false
	_after_trigger()
	
func trigger_internal(tilemap: TileMap):
	pass

func move(new_location: Vector2i, new_global_location: Vector2i):
	location = new_location
	global_location = new_global_location
	border_animation.position = new_global_location
	border_animation.modulate = color
