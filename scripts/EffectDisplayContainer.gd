extends CanvasLayer

class_name EffectDisplayContainer

@onready var timer = $Timer
@onready var display_preload = preload("res://scenes/EffectDisplay.tscn")
@onready var grid = $Panel/ColorRect/MarginContainer/GridContainer
var seen_effects: Array[String] = []

func _ready():
	self.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func clear_entries():
	for child in grid.get_children():
		child.queue_free()

func display(spawner: PieceSpawner):
	clear_entries()
	var temp_added_count: int = 0
	if len(spawner.latest_effects) == 0:
		return
	for le in spawner.latest_effects:
		if le.name in seen_effects and not le.is_upgrade:
			continue
		var new_display = display_preload.instantiate()
		new_display.set_values(le)
		grid.add_child(new_display)
		seen_effects.append(le.name)
		temp_added_count += 1
	# Check if we actually added any.
	if temp_added_count > 0:
		self.visible = true
		timer.start()
	else:
		self.visible = false
	
	
func _on_timer_timeout():
	for child in grid.get_children():
		child.queue_free()
	self.visible = false
