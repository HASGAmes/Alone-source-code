class_name Tile
extends Sprite2D

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
var is_explored: bool = false:
	set(value):
		is_explored = value
		if is_explored and not visible:
			visible = true

var is_in_view: bool = false:
	set(value):
		is_in_view = value
		modulate = chosen_light_color if is_in_view else chosen_dark_color
		if is_in_view and not is_explored:
			is_explored = true


func _init(grid_position: Vector2i, tile_definition: TileDefinition) -> void:
	visible = false
	centered = false
	self.grid_position = grid_position
	position = Grid.grid_to_world(grid_position)
	set_tile_type(tile_definition)
	walkable = tile_definition.is_walkable
	transparent = tile_definition.is_transparent
	
func distance(other_position: Vector2i) -> float:
	var relative: Vector2i = other_position - grid_position
	return relative.length()

func set_tile_type(tile_definition: TileDefinition) -> void:
	_definition = tile_definition.duplicate()
	randomize()
	var size = _definition.texture.size()
	var random_num: int = randi_range(0,size-1)
	var random_texture = _definition.texture.pop_at(random_num)
	texture = random_texture
	rubble_texture = _definition.rubble
	openable = tile_definition.is_openable
	open_texture = tile_definition.open_texture
	closed_texture = tile_definition.closed_texture
	chosen_dark_color =_definition.color_dark.pop_at(random_num)
	chosen_light_color = _definition.color_lit.pop_at(random_num)
	modulate = chosen_dark_color
	destructible = _definition.is_destructible
	tile_name = _definition.name
	max_hp = _definition.max_hp
	hp = max_hp
	defense = _definition.def
	DV = _definition.DV
	rubble_color = _definition.rubble_color
	terrain_effect = _definition.terrain_effect
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
