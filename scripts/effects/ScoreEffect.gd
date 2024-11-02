extends Effect

class_name ScoreEffect
@export var score_amount: int = 500

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func trigger_internal(tilemap: TileMap):
	tilemap.score += score_amount
