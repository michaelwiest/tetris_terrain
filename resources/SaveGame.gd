extends Resource
class_name SaveGame

const SAVE_GAME_PATH: String = "res://resources/game_data/SaveGame.tres"

@export var level_index_save_map: Array[LevelData] = []


func save_data():
	ResourceSaver.save(self, SAVE_GAME_PATH)

func save_level(level_data: LevelData):
	if _has_level_data(level_data.level_id):
		level_index_save_map.erase(level_data)
	level_index_save_map.append(level_data)
	save_data()
		

static func load_all_data() -> SaveGame:
	if ResourceLoader.exists(SAVE_GAME_PATH):
		return load(SAVE_GAME_PATH)
	return null

	
static func _load_level_data(level_id: int) -> LevelData:
	for li in load_all_data().level_index_save_map:
		if li.level_id == level_id:
			return li
	return null
	
func _has_level_data(level_id: int) -> bool:
	level_index_save_map = load_all_data().level_index_save_map
	for li in load_all_data().level_index_save_map:
		if li.level_id == level_id:
			return true
	return false
