extends CanvasLayer

class_name LevelHud

@onready var high_value: Label = %HighValue
@onready var streak_value: Label = %StreakValue
@onready var score_value: Label = %ScoreValue
@onready var goal_value: Label = %GoalValue

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_score(new_score: int) -> void:
	score_value.text = str(new_score)

func set_streak(new_streak: int) -> void:
	streak_value.text = str(new_streak)
	
func set_high(new_score: int) -> void:
	high_value.text = str(new_score)

func set_goal(goal: int) -> void:
	goal_value.text = str(goal)
