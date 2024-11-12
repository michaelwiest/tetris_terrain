extends CanvasLayer

class_name EffectDisplayContainer

@onready var timer = $Timer
@onready var display_preload = preload("res://scenes/EffectDisplay.tscn")
@onready var grid = $Panel/MarginContainer/GridContainer
@export var display_time: int = 3
var seen_effects: Array[String] = []
@onready var tween = create_tween()
func _ready():
	self.visible = false
	timer.wait_time = display_time
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reset():
	seen_effects = []

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
		grid.add_child(new_display)
		new_display.set_values(le)
		
		seen_effects.append(le.name)
		temp_added_count += 1
	# Check if we actually added any.
	if temp_added_count > 0:
		self.visible = true
#		tween_into_frame()
		timer.start()
	else:
		self.visible = false
#		tween_out_of_frame()
	
	
func _on_timer_timeout():
	for child in grid.get_children():
		child.queue_free()
	self.visible = false
#	tween_out_of_frame()

func tween_into_frame():
#	var tween = get_tree().create_tween()
#	tween.tween_property(self, "transform.origin", transform.origin + Vector2(0, 224), 1)
	transform.origin += Vector2(0, 100)
	print("tweening?")

func tween_out_of_frame():
#	var tween = get_tree().create_tween()
#	tween.tween_property(self, "transform.origin", transform.origin - Vector2(0, 224), 1)
	transform.origin -= Vector2(0, 100)
