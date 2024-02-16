extends TextureRect
@export var entity:EntityDefinition
@export var tile:TileDefinition
@onready var object_cursor:Node2D 
@onready var cursor_sprite
var shader_og_sec = Color("e9b0e6")
var shader_og_prim = Color("fffcce")
signal showname(name)
func _ready():
	connect("mouse_entered",_on_mouse_entered)
	connect("gui_input",item_clicked)
	if tile!=null:
		var text = tile.texture.duplicate()
		texture = text.pop_front()
		material.set_shader_parameter("og_primary_color",shader_og_prim)
		material.set_shader_parameter("og_secondary_color",shader_og_sec)
		material.set_shader_parameter("primary_color",tile.color_lit_prim)
		material.set_shader_parameter("secondary_color",tile.color_lit_sec)
	elif entity!=null:
		texture = entity.texture
		material.set_shader_parameter("og_primary_color",shader_og_prim)
		material.set_shader_parameter("og_secondary_color",shader_og_sec)
		material.set_shader_parameter("primary_color",entity.primary_color)
		material.set_shader_parameter("secondary_color",entity.secondary_color)
func item_clicked(event):
	if (event is InputEvent):
		if(event.is_action_pressed("mb_click")):
			object_cursor.current_item = entity
			object_cursor.current_tile = tile
			cursor_sprite.texture = texture
			cursor_sprite.material = material
	pass

func _on_mouse_entered():
	if tile!=null:
		showname.emit(tile.name)
	elif entity!=null:
		showname.emit(entity.name)
	pass # Replace with function body.
