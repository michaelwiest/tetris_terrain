extends Control

class_name EffectDisplay

@onready var display_name = $Panel/MarginContainer/VBoxContainer/Name
@onready var description = $Panel/MarginContainer/VBoxContainer/Description
@onready var icon = $Panel/MarginContainer/Icon
@onready var name_object: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Name

# Called when the node enters the scene tree for the first time.
func _ready():
	name_object.add_theme_font_size_override("font_size", 12)


func set_values(effect: Effect):
	var tr = get_node("%TextureRect")
	tr.get_parent().add_child(effect)
	effect._ready()
	# Magic numbers
	effect.position += Vector2(32, 32)
#	var name_label = get_node("%Name")
	name_object.text = effect.display_name
#	_on_line_edit_text_changed(name_label, effect.display_name)
	get_node("%Description").text = effect.description
	if effect.icon:
		tr.texture = effect.icon.texture



func _on_line_edit_text_changed(name_label: Label, new_text):
	name_label.text = new_text
	name_object.add_theme_font_size_override("font_size", 12)
#	if len(new_text) > 8:
#		name_label.add_theme_font_size_override("font_size", 12)
#		name_label.Label/font_size/font_size = 23

#	# Adjust name's font size to fit within the allowed width.
#	var current_size = 32
#	name_label.add_theme_font_size_override("font_size", current_size)
##	print(name_label.font_size)
#	while name_label.font.get_string_size(name_label.text, name_label.horizontal_alignment, -1, current_size).x > name_label.width:
#		current_size -= 1
#		name_label.add_theme_font_size_override("font_size", current_size)
