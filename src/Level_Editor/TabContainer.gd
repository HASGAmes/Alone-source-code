extends TabContainer

@onready var object_cursor :Node2D =%"Editor_Object"
@onready var button = preload("res://src/Level_Editor/editor_objects/item_texture.tscn")
@export var enemyDir :String = "res://assets/definitions/entities/actors/"
@export var itemDir :String ="res://assets/definitions/entities/items/"
@export var tileDir: String ="res://assets/definitions/tiles/"
@onready var actor_block = $Actors/VBoxContainer/HBoxContainer
@onready var item_block = $Items/VBoxContainer/HBoxContainer
@onready var tile_block = $Tiles/VBoxContainer/HBoxContainer
@onready var game = %"Game"
@onready var input:InputHandler = game.input_handler
func _ready():
	add_buttons(tileDir,tile_block,true)
	add_buttons(enemyDir,actor_block,false)
	add_buttons(itemDir,item_block,false)
	SignalBus.editor_open = true
	get_parent().visible = !SignalBus.editor_open
	get_node("/root/GameManager/InterfaceRoot/InfoBar").visible = SignalBus.editor_open
	get_node("/root/GameManager/InterfaceRoot/VBoxContainer/gamebox/HBoxContainer").visible = SignalBus.editor_open
func _process(delta):
	if Input.is_action_just_pressed("toggle editor"):
		SignalBus.editor_open = !SignalBus.editor_open
		if SignalBus.editor_open ==false:
			get_parent().visible = !SignalBus.editor_open
			input.transition_to(InputHandler.InputHandlers.LEVEL_EDITOR)
			
		else:
			get_parent().visible = !SignalBus.editor_open
			input.transition_to(InputHandler.InputHandlers.MAIN_GAME)
			print(SignalBus.editor_open)
			SignalBus.iseeall = visible
		object_cursor.level.get_parent().update_fov(SignalBus.player.grid_position)
		get_node("/root/GameManager/InterfaceRoot/InfoBar").visible = SignalBus.editor_open
		get_node("/root/GameManager/InterfaceRoot/VBoxContainer/gamebox/HBoxContainer").visible = SignalBus.editor_open
	if %"Editor_Object".current_state == %"Editor_Object".EDITOR_MODE.DRAWING:
		visible = true
	else:
		visible = false
func _on_mouse_entered():
	object_cursor.can_place = false
	object_cursor.hide()
	pass # Replace with function body.

func add_buttons(path:String,adding_node:HBoxContainer,is_tile:bool):
	var dir = DirAccess
	dir = dir.open(path)
	var first:Array= dir.get_files()
	while !first.is_empty():
		var file= first.pop_front()
		if file.ends_with(".remap"):
			file= file.trim_suffix(".remap")
			
		var current = load(path+file)
		var but = button.instantiate()
		if is_tile == true:
			but.tile = current
		else:
			but.entity = current
		adding_node.add_child(but)
		but.showname.connect(%"MouseoverLabel".text_set)
		but.object_cursor=%"Editor_Object"
		but.cursor_sprite = object_cursor.get_node("Sprite")
func _on_mouse_exited():
	if visible == true:
		object_cursor.can_place = true
	object_cursor.show()
	pass # Replace with function body.

func _on_drawmode_mouse_entered():
	object_cursor.can_place = false
	object_cursor.hide()
	pass # Replace with function body.


func _on_erasemode_mouse_entered():
	object_cursor.can_place = false
	object_cursor.hide()
	pass # Replace with function body.


func _on_modifymode_mouse_entered():
	object_cursor.can_place = false
	object_cursor.hide()
	pass # Replace with function body.


func _on_drawmode_mouse_exited():
	if visible == true:
		object_cursor.can_place = true
	object_cursor.show()
	pass # Replace with function body.


func _on_erasemode_tree_exiting():
	if visible == true:
		object_cursor.can_place = true
	object_cursor.show()
	pass # Replace with function body.


func _on_modifymode_mouse_exited():
	if visible == true:
		object_cursor.can_place = true
	object_cursor.show()
	pass # Replace with function body.
