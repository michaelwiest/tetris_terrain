extends Control

class_name EffectDisplay

@onready var display_name = $Panel/MarginContainer/VBoxContainer/Name
@onready var description = $Panel/MarginContainer/VBoxContainer/Description
@onready var icon = $Panel/MarginContainer/Icon

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func set_values(effect: Effect):
	var tr = get_node("Panel/MarginContainer/HBoxContainer/MarginContainer/TextureRect")
	tr.get_parent().add_child(effect)
	effect._ready()
	# Magic numbers
	effect.position += Vector2(48, 32)
	get_node("Panel/MarginContainer/HBoxContainer/VBoxContainer/Name").text = effect.display_name
	get_node("Panel/MarginContainer/HBoxContainer/VBoxContainer/Description").text = effect.description
	if effect.icon:
		get_node("Panel/MarginContainer/HBoxContainer/MarginContainer/TextureRect").texture = effect.icon.texture
