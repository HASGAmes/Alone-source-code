class_name Component
extends Node

@onready var entity: Entity = get_parent() as Entity
@onready var tile: Tile = get_parent() as Tile


func get_map_data() -> MapData:
	return entity.map_data
func get_tile_map_data() -> MapData:
	return tile.map_data
