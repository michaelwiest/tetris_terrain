extends Panel

@export var recipe: Recipe

@onready var panel: Panel = $Panel

@onready var piece_display: PieceDisplay = $MarginContainer/MarginContainer/PieceDisplay
@onready var color_rect: ColorRect = $ColorRect
@onready var display_name: Label = $DisplayName
# Called when the node enters the scene tree for the first time.
func _ready():
	if recipe:
		if not piece_display.piece:
			piece_display.set_piece(recipe.piece)
		color_rect.color = recipe.display_color
		display_name.text = recipe.display_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_tileset(tile_set: TileSet):
	piece_display.set_tileset(tile_set)
