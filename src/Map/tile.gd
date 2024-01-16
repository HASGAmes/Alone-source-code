class_name Tile
extends Sprite2D
const tile_types = {
	"floor": preload("res://assets/definitions/tiles/tile_definition_floor.tres"),
	"wall": preload("res://assets/definitions/tiles/tile_definition_wall.tres"),
	"rocks": preload("res://assets/definitions/tiles/tile_definition_rocks.tres"),
	"door": preload("res://assets/definitions/tiles/tile_definition_door.tres"),
	"bones":preload("res://assets/definitions/tiles/tile_definition_skulls.tres"),
	"blank":preload("res://assets/definitions/tiles/blank.tres")
}
var key: String
var _definition: TileDefinition
var walkable
var transparent
var openable
signal hp_changed(hp, max_hp)
var tile_name
var max_hp: int
var hp: int:
	set(value):
		hp = clampi(value, 0, max_hp)
		hp_changed.emit(hp, max_hp)
		if hp <= 0:
			destroy()
var defense: int
var DV
var opened = false
var open_texture: AtlasTexture
var closed_texture: AtlasTexture
var chosen_light_color
var chosen_dark_color
var rubble_texture: AtlasTexture
var rubble_color:Color
var destructible:bool
var terrain_effect
var grid_position:Vector2i
var collision = preload("res://assets/resources/raycast_body.tscn")
var is_explored: bool = false:
	set(value):
		if SignalBus.iseeall == true:
			#print("fsadfs")
			#is_in_view = true
			is_explored = true
		else:
			is_explored = value
		if is_explored and not visible:
			visible = true
var is_in_view: bool = false:
	set(value):
		if SignalBus.iseeall == true:
			#print("fsadfs")
			is_in_view = true
			#is_explored = true
		else:
			is_in_view = value
		modulate = chosen_light_color if is_in_view else chosen_dark_color
		if is_in_view and not is_explored:
			is_explored = true


func _init(grid_position: Vector2i, key: String) -> void:
	visible = false
	centered = false
	position = Grid.grid_to_world(grid_position)
	set_tile_type(key)
	self.grid_position = grid_position
	global_position = Grid.grid_to_world(grid_position)
	collision = collision.instantiate()
	add_child(collision)
	collision.position = Vector2i(8,8)
	
	
func distance(other_position: Vector2i) -> int:
	var distance_x = other_position.x-grid_position.x
	
	var distance_y = other_position.y-grid_position.y
	if distance_x<0:
		distance_x*=-1
	if distance_y<0:
		distance_y*=-1
	var distance:int
	if distance_x>distance_y:
		distance = distance_x
	if distance_y>distance_x:
		distance = distance_y
	if distance_x == distance_y:
		distance=distance_x
	return distance

func set_tile_type(key: String) -> void:
	self.key = key
	_definition = tile_types[key]
	_definition = _definition.duplicate()
	randomize()
	var size = _definition.texture.size()
	var random_num: int = randi_range(0,size-1)
	var random_texture = _definition.texture.pop_at(random_num)
	texture = random_texture
	rubble_texture = _definition.rubble
	openable = _definition.is_openable
	open_texture = _definition.open_texture
	closed_texture = _definition.closed_texture
	chosen_dark_color =_definition.color_dark.pop_at(random_num)
	chosen_light_color = _definition.color_lit.pop_at(random_num)
	walkable = _definition.is_walkable
	transparent = _definition.is_transparent
	modulate = chosen_dark_color
	destructible = _definition.is_destructible
	tile_name = _definition.name
	max_hp = _definition.max_hp
	hp = max_hp
	defense = _definition.def
	DV = _definition.DV
	rubble_color = _definition.rubble_color
	terrain_effect = _definition.terrain_effect
#	if !is_walkable():
#		collision.collision_layer = 8
#	else:
#		collision.collision_layer = 0
		
func open_or_close():
	if opened == false:
		_definition.is_transparent = true
		walkable = true
		_definition.is_walkable = true
		texture = open_texture
		opened = true
	else:
		_definition.is_transparent = false
		walkable = false
		_definition.is_walkable = false
		texture = closed_texture
		opened = false

func is_walkable() -> bool:
	return _definition.is_walkable
	
func is_slippery() -> bool:
	return _definition.is_slippery
	
func is_transparent() -> bool:
	return _definition.is_transparent
	
func is_destructible() -> bool:
	return _definition.is_destructible
	
func get_save_data() -> Dictionary:
	return {
		"key": key,
		"is_explored": is_explored
	}


func restore(save_data: Dictionary) -> void:
	set_tile_type(save_data["key"])
	is_explored = save_data["is_explored"]

func destroy() -> void:
	var death_message: String
	var death_message_color: Color
	death_message_color = GameColors.ENEMY_DIE
	death_message+="wall destroyed"
	texture = rubble_texture
	_definition.is_transparent = true
	chosen_dark_color = rubble_color
	chosen_light_color = rubble_color
	walkable = true
	_definition.is_walkable = true
	destructible = false
	MessageLog.send_message(death_message, death_message_color)
