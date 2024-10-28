extends Node2D

class_name Effect

enum Type {BOARD_ALTER, MATCH_ALTER, UPGRADE}
@onready var active: bool = false
@export var location: Vector2i = Vector2i(-1, -1)
var global_location: Vector2i = Vector2i(-1, -1)
@export var type: Type = Type.MATCH_ALTER
@onready var border_animation = $BorderAnimation
@export var color: Color = Color(1, 1, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	border_animation.modulate = color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func trigger(tilemap: TileMap):
	if active:
		trigger_internal(tilemap)
	
func trigger_internal(tilemap: TileMap):
	pass

func move(new_location: Vector2i, new_global_location: Vector2i):
	location = new_location
	global_location = new_global_location
	border_animation.position = new_global_location
	border_animation.modulate = color
