extends Panel

@export var recipe: Recipe

@onready var panel: Panel = $Panel

@onready var piece_display: PieceDisplay = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Container/PieceDisplay
@onready var display_name: Label = $MarginContainer/VBoxContainer/DisplayName
@onready var color_bar: ColorRect = $ColorRect
var texture_rects: Array[TextureRect] = []
var textures: Array[Texture] = []
# Called when the node enters the scene tree for the first time.
func _ready():
	if recipe:
		if not piece_display.piece:
			piece_display.set_piece(recipe.piece)
		display_name.text = recipe.display_name
		color_bar.modulate = recipe.display_color
#		display_name.text.color = Color(1, 1, 1)
	for tr in get_node("MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/MarginContainer/GridContainer").get_children():
		texture_rects.append(tr)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if recipe and len(recipe.upgrades) > len(textures):
		for i in range(len(recipe.upgrades)):
			texture_rects[i].texture = recipe.upgrades[i].icon.texture
		


func set_tileset(tile_set: TileSet):
	piece_display.set_tileset(tile_set)
