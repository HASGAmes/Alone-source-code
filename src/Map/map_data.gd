class_name MapData
extends RefCounted

signal entity_placed(entity)



const entity_pathfinding_weight = 15.0

var width: int
var height: int
var tiles: Array[Tile]
var entities: Array[Entity]
var player: Entity
var pathfinder: AStarGrid2D


func _init(map_width: int, map_height: int, player: Entity) -> void:
	width = map_width
	height = map_height
	self.player = player
	entities = []
	_setup_tiles()


func _setup_tiles() -> void:
	tiles = []
	for y in height:
		for x in width:
			var tile_position := Vector2i(x, y)
			var tile := Tile.new(tile_position, "wall")
			tiles.append(tile)



func is_in_bounds(coordinate: Vector2i) -> bool:
	return (
		0 <= coordinate.x
		and coordinate.x < width
		and 0 <= coordinate.y
		and coordinate.y < height
	)


func get_tile_xy(x: int, y: int) -> Tile:
	var grid_position := Vector2i(x, y)
	return get_tile(grid_position)


func get_tile(grid_position: Vector2i) -> Tile:
	var tile_index: int = grid_to_index(grid_position)
	if tile_index == -1:
		return null
	return tiles[tile_index]


func get_blocking_entity_at_location(grid_position: Vector2i) -> Entity:
	var tile_index: int = grid_to_index(grid_position)
	for entity in entities:
		if entity.is_blocking_movement() and entity.grid_position == grid_position:
			return entity
	return null

func get_entity_location(grid_position:Vector2i) ->Entity:
	var entity_index: int = grid_to_index(grid_position)
	if entity_index == -1:
		return null
	return entities[entity_index]
func grid_to_index(grid_position: Vector2i) -> int:
	if not is_in_bounds(grid_position):
		return -1
	return grid_position.y * width + grid_position.x


func setup_pathfinding() -> void:
	pathfinder = AStarGrid2D.new()
	pathfinder.region = Rect2i(0, 0, width, height)
	pathfinder.update()
	for y in height:
		for x in width:
			var grid_position := Vector2i(x, y)
			var tile: Tile = get_tile(grid_position)
			pathfinder.set_point_solid(grid_position, tile.walkable ==true)
	for entity in entities:
		if entity.is_blocking_movement():
			register_blocking_entity(entity)


func register_blocking_entity(entity: Entity) -> void:
	pathfinder.set_point_weight_scale(entity.grid_position, entity_pathfinding_weight)


func unregister_blocking_entity(entity: Entity) -> void:
	pathfinder.set_point_weight_scale(entity.grid_position, 0)
	
func get_tiles() ->Array[Tile]:
	var list_Tiles:Array[Tile] = []
	for tile in tiles:
		list_Tiles.append(tile)
	return list_Tiles

func get_actors() -> Array[Entity]:
	var actors: Array[Entity] = []
	for entity in entities:
		if entity.get_entity_type() == Entity.EntityType.ACTOR and entity.is_alive():
			actors.append(entity)
	return actors


func get_items() -> Array[Entity]:
	var items: Array[Entity] = []
	for entity in entities:
		if entity.consumable_component != null or entity.equipment_item_component!=null:
			items.append(entity)
	return items


func get_actor_at_location(location: Vector2i) -> Entity:
	for actor in get_actors():
		if actor.grid_position == location:
			return actor
	return null
func get_item_at_location(location:Vector2i)->Entity:
	for item in get_items():
		if item.grid_position == location:
			return item
	return null
func diagonal_distance(p0, p1):
	var dvector = Vector2i(p1.x - p0.x, p1.y - p0.y)
	return max(abs(dvector.x), abs(dvector.y))


func lerp(start, end, t):
	return start * (1.0 - t) + t * end


func lerp_line(p0, p1):
	var points = []
	var N = diagonal_distance(p0, p1)
	var step = 0
	while  step <= N:
		step+=1
		var t = N 
		if N != 0:
			t = step/N
		var x = round(lerp(p0.x, p1.x, t))
		var y = round(lerp(p0.y, p1.y, t))
		points.append(Vector2i(x,y))
	return points

func get_save_data() -> Dictionary:
	var save_data := {
		"width": width,
		"height": height,
		"player": player.get_save_data(),
		"entities": [],
		"tiles": []
	}
	for entity in entities:
		if entity == player:
			continue
		save_data["entities"].append(entity.get_save_data())
	for tile in tiles:
		save_data["tiles"].append(tile.get_save_data())
	return save_data

func restore(save_data: Dictionary) -> void:
	width = save_data["width"]
	height = save_data["height"]
	_setup_tiles()
	for i in tiles.size():
		tiles[i].restore(save_data["tiles"][i])
	setup_pathfinding()
	player.restore(save_data["player"])
	player.map_data = self
	entities = [player]
	for entity_data in save_data["entities"]:
		var new_entity := Entity.new(self, Vector2i.ZERO, "")
		new_entity.restore(entity_data)
		entities.append(new_entity)
		
func save() -> void:
	var file = FileAccess.open("res://assets/saves/save_game.dat", FileAccess.WRITE)
	var save_data: Dictionary = get_save_data()
	var save_string: String = JSON.stringify(save_data)
	var save_hash: String = save_string.sha256_text()
	file.store_line(save_hash)
	file.store_line(save_string)
func load_game() -> bool:
	var file = FileAccess.open("res://assets/saves/save_game.dat", FileAccess.READ)
	var retrieved_hash: String = file.get_line()
	var save_string: String = file.get_line()
	var calculated_hash: String = save_string.sha256_text()
	var valid_hash: bool = retrieved_hash == calculated_hash
	if not valid_hash:
		return false
	var save_data: Dictionary = JSON.parse_string(save_string)
	restore(save_data)
	return true
