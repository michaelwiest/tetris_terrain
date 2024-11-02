extends Effect

class_name UpgradeEffect
@export var upgrade: Upgrade:
	get:
		return upgrade
	set(new_value):
		description = new_value.description
		upgrade = new_value
		icon = new_value.icon
		display_name = new_value.display_name
		color = new_value.color
		
		
@export var piece_spawner_upgrade_index: int


signal upgrade_added(index: int)

# Gross hack to draw flame animation.
func _process(delta):
	pass

func _ready():
	is_upgrade = true
	self.border_animation.modulate = color

func trigger_internal(tilemap: TileMap):
#	tilemap.matched_recipe.add_child(upgrade)
	tilemap.matched_recipe.set_upgrades(upgrade)
	upgrade_added.emit(piece_spawner_upgrade_index)
