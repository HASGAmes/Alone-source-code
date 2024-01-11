extends TextureRect
@export var this_scene:EntityDefinition
@onready var object_cursor:Node2D =%"Editor_Object"
@onready var cursor_sprite = object_cursor.get_node("Sprite")
func _ready():
	connect("gui_input",item_clicked)
	texture = this_scene.texture
	modulate = this_scene.color
	


func item_clicked(event):
	if (event is InputEvent):
		if(event.is_action_pressed("mb_click")):
			object_cursor.current_item = this_scene
			print("click")
			cursor_sprite.texture = texture
			
	pass
