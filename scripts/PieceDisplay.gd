extends Control
class_name PieceDisplay

@onready var tilemap: TileMap = $TileMap
@export var offset: Vector2i = Vector2i(1, 1)
@onready var piece: Piece
@export var tilemap_scale: Vector2 = Vector2(1.0, 1.0)
# Called when the node enters the scene tree for the first time.
func _ready():
	tilemap.scale = tilemap_scale


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_tileset(tile_set: TileSet):
	tilemap.tile_set = tile_set

func clear_piece():
	piece.clear(tilemap, 0, offset)
func draw_piece():
	# Hack need to have these zeros be set.
	piece.draw(tilemap, 0, offset, 0)
	
func set_piece(new_piece: Piece):
	if piece:
		clear_piece()
	piece = new_piece
	draw_piece()
