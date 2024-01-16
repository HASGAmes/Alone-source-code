## the class of all the tiles in my roguelike
class_name Tile
extends Sprite2D
##these are loaded on launch from the tile definition folder
## if more is added then they are automatically added to this dictionary without any other requirements
var tile_types:Dictionary
var key: String## the key to a part of the tile type dict.created from the name of the tile definition
var _definition: TileDefinition
var walkable##if walkable
var transparent##if you can see through
var openable##if you can open it
signal hp_changed(hp, max_hp)
var tile_name
var max_hp: int
var hp: int:
	set(value):
		hp = clampi(value, 0, max_hp)
		hp_changed.emit(hp, max_hp)
		if hp <= 0:
			destroy()
var defense: int##defense of a tile. 
var DV##only here for the melee action
var opened = false##if true you can go through this door
var open_texture: AtlasTexture##opened texture
var closed_texture: AtlasTexture##closed texture
var chosen_light_color## the color of a tile you can see
var chosen_dark_color## the color of a tile you can't see
var rubble_texture: AtlasTexture## texture of a destroyed tile
var rubble_color:Color##destroyed tile color
var destructible:bool## if true you can destroy this
var terrain_effect##if something is here entities that walk on it can get the status
var grid_position:Vector2i##where the tile is
var collision = preload("res://assets/resources/raycast_body.tscn")
var tile_path:String = "res://assets/definitions/tiles/"
var is_explored: bool = false:## if true you have been here
	set(value):
		if SignalBus.iseeall == true:
			#print("fsadfs")
			#is_in_view = true
			is_explored = true
		else:
			is_explored = value
		if is_explored and not visible:
			visible = true
var is_in_view: bool = false:##if true you can see it
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
	update_keys(tile_path)
	position = Grid.grid_to_world(grid_position)
	
	self.grid_position = grid_position
	global_position = Grid.grid_to_world(grid_position)
	collision = collision.instantiate()
	add_child(collision)
	collision.position = Vector2i(8,8)
	set_tile_type(key)
##gets the tile path and creates the tile types from that so you don't have to
## add them each time you create a new tile
func update_keys(path:String):
	var dir = DirAccess
	dir.open(path)
	var current:String
	var first:Array= dir.get_files_at(path)
	while !first.is_empty():
		current = first.pop_front()
		var dict:Dictionary ={current.left(current.length()-5).to_lower():path+current}
		tile_types.merge(dict)
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
	var tile_definition:TileDefinition = load(tile_types[key])
	_definition = tile_definition
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
