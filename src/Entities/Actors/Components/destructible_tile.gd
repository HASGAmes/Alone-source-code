class_name Destructible_Tile
extends Component
signal hp_changed(hp, max_hp)

var max_hp: int
var hp: int:
	set(value):
		hp = clampi(value, 0, max_hp)
		hp_changed.emit(hp, max_hp)
		
var defense: int
var rubble_texture: Texture
func _init(definition: Destructible_Tile_Definition) -> void:
	max_hp = definition.max_hp
	rubble_texture = definition.rubble
	#tile = destroyed_tile
	hp = definition.max_hp
	defense = definition.def

