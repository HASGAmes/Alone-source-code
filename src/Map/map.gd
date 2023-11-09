class_name Map
extends Node2D

var map_data: MapData

@onready var tiles: Node2D = $Tiles
@onready var entities: Node2D = $Entities
@onready var dungeon_generator: DungeonGenerator = $DungeonGenerator
@onready var field_of_view: FieldOfView = $FieldOfView
@export var fov_radius:int 
@onready var screeneffects:CanvasModulate = $screeneffects
func generate(player: Entity) -> void:
	map_data = dungeon_generator.generate_dungeon(player)
	map_data.entity_placed.connect(entities.add_child)
	_place_tiles()
	_place_entities()


func update_fov(player_position: Vector2i) -> void:
	field_of_view.update_fov(map_data, player_position, fov_radius)
	
	for entity in map_data.entities:
		entity.visible = map_data.get_tile(entity.grid_position).is_in_view
#func line(p0, p1):
#	var points = [];
#	var N = diagonal_distance(p0, p1);
#	for (let step = 0; step <= N; step++)
#		let t = N === 0? 0.0 : step / N
#	points.push(round_point(lerp_point(p0, p1, t)))
#	return points


func _place_tiles() -> void:
	for tile in map_data.tiles:
		tiles.add_child(tile)


func _place_entities() -> void:
	for entity in map_data.entities:
		entities.add_child(entity)
