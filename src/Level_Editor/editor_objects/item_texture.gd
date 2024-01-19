extends TextureRect
@export var entity:EntityDefinition
@export var tile:TileDefinition
@onready var object_cursor:Node2D 
@onready var cursor_sprite
signal showname(name)
func _ready():
	connect("mouse_entered",_on_mouse_entered)
	connect("gui_input",item_clicked)
	if tile!=null:
		var text = tile.texture.duplicate()
		var col = tile.color_lit.duplicate()
		texture = text.pop_front()
		modulate = col.pop_front()
	elif entity!=null:
		texture = entity.texture
		modulate = entity.color
func item_clicked(event):
	if (event is InputEvent):
		if(event.is_action_pressed("mb_click")):
			object_cursor.current_item = entity
			object_cursor.current_tile = tile
			cursor_sprite.texture = texture
			
	pass

func _on_mouse_entered():
	if tile!=null:
		showname.emit(tile.name)
	elif entity!=null:
		showname.emit(entity.name)
	pass # Replace with function body.
