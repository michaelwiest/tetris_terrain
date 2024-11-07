extends CanvasLayer

var button_index: int = 0
var buttons: Array[Button] = []
@onready var button_box = $Control/MarginContainer/VBoxContainer
#@onready var level: Level = $".."
var is_paused: bool = true
var selected_button: Button
var can_listen_for_cancel = false

@export_multiline var success_message: String
@export_multiline var failure_message: String
var succeeded: bool = false
var particle = preload("res://scenes/animations/explosion.tscn")
@onready var success_state_panel: Control = $Control/MarginContainer/VBoxContainer/Control
@onready var message_node: Label = $Control/MarginContainer/VBoxContainer/Control/MarginContainer/message
@onready var next_level_button: Button = $Control/MarginContainer/VBoxContainer/NextLevel
@onready var timer = $Timer
var can_receive_click: bool = true

func _ready():
#	visible = false
	for maybe_button in button_box.get_children():
		if maybe_button is Button:
			buttons.append(maybe_button)
	selected_button = buttons[0]
	
	message_node.text = success_message
	set_success_state(succeeded)
	


func set_paused():
	visible = !visible
	is_paused = !is_paused
	can_listen_for_cancel = false

func do_animation():
	for i in range(10):
		var new_ani = particle.instantiate()
		success_state_panel.add_child(new_ani)
		new_ani.restart()

func _process(delta):
#	print(is_paused)
	if is_paused:
		if Input.is_action_just_pressed("ui_down"):
			button_index += 1
		elif Input.is_action_just_pressed("ui_up"):
			button_index -= 1
			if button_index < 0:
				button_index = len(buttons) - 1
		if Input.is_action_just_pressed("ui_accept") and can_receive_click:
			selected_button.pressed
			can_receive_click = false
			timer.start()
			
		button_index = button_index % len(buttons)
		selected_button = buttons[button_index]
		selected_button.grab_focus()
	
#
func set_success_state(success: bool):
	succeeded = success
	next_level_button.disabled = not succeeded
	if succeeded:
		message_node.text = success_message
	else:
		message_node.text = failure_message

#func _on_resume_pressed():
#	level.pause_game()
#
#
#func _on_new_game_pressed():
#	level.new_game()
#	level.pause_game()


func _on_new_game_pressed():
	print("ng click")
	do_animation()


func _on_next_level_pressed():
	if succeeded:
		print("Next level!")


func _on_main_menu_pressed():
	print("in button click")
	set_success_state(!succeeded)


func _on_timer_timeout():
	can_receive_click = true
