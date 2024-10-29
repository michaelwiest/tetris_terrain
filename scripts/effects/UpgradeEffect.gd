extends Effect

class_name UpgradeEffect
@export var upgrade: Upgrade
@export var piece_spawner_upgrade_index: int

signal upgrade_added(index: int)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Gross hack to draw flame animation.
func _process(delta):
	pass


func trigger_internal(tilemap: TileMap):
	tilemap.matched_recipe.add_child(upgrade)
	tilemap.matched_recipe.set_upgrades()
	upgrade_added.emit(piece_spawner_upgrade_index)
