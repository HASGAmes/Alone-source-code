class_name TileDefinition
extends Resource

@export_category("Visuals")
#name of tiles
@export var name:String="unnamed tile"
#list of textures for tiles to randomly be
@export var texture: Array[AtlasTexture]
@export var color_lit: Array[Color]
@export var color_dark:Array[Color]
@export var rubble :AtlasTexture
@export var rubble_color:Color
@export var open_texture:AtlasTexture
@export var closed_texture:AtlasTexture
@export_category("Stats")
@export var max_hp: int
@export var def: int
@export var DV:int = -15


@export_category("Mechanics")
@export var is_walkable: bool = true
@export var is_transparent: bool = true
@export var is_destructible:bool = false
@export var is_openable: bool = false
@export var is_slippery: bool = false
@export var terrain_effect:StatusEffectDefinition
