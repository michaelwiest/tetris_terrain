extends Node2D

class_name Effect

enum Type {BOARD_ALTER, MATCH_ALTER, UPGRADE}
@onready var active: bool = false
@export var location: Vector2i = Vector2i(-1, -1)
@onready var animation = $animation
@export var type: Type = Type.MATCH_ALTER

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func trigger(tilemap: TileMap):
	pass

