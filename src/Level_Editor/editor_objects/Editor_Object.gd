##This is the main node running the level editor
class_name EditorObject
extends Node2D

var can_place = true##if true can interact using current mode
var is_panning = true## if true can use middle mouse to pan
enum EDITOR_MODE {DRAWING,ERASING,MODIFY}##all the modes of the editor
var current_state = EDITOR_MODE.DRAWING##default mode is drawing
var cam_spd = 10##speed of camera
@onready var level:Node2D =%"Game"/Map/Entities
@onready var tiles:Node2D = %"Game"/Map/Tiles
@onready var editor:Node2D = %"cameracontainer"
@onready var editor_cam:Camera2D = %"editorcam"
@onready var mouse_checker_tile:Node2D = %"MouseoverChecker"
@onready var notexture:Texture = preload("res://src/Level_Editor/cannot.png")
@onready var cantexture:Texture = preload("res://src/Level_Editor/can.png")
var current_item:EntityDefinition
var current_tile:TileDefinition
var erase_tool = preload("res://src/Level_Editor/erasetool.tres")
@onready var player_cam:Camera2D = %"Camera2D"
signal mouse_coords(vector2i)##updates the gridposition of the mouse for convience
signal canplace(texture)##a texture that shows if you can interact or not
func _ready():
	canplace.connect(canplacetexture)
	pass


func _process(delta):
	
	var map:Map = level.get_parent()
	var mapdata:MapData = map.map_data
	global_position = mouse_checker_tile._mouse_tile*16
	var mx = str(mouse_checker_tile._mouse_tile.x)
	var my = str(mouse_checker_tile._mouse_tile.y)
	if can_place == false:
		canplace.emit(notexture)
	else:
		canplace.emit(cantexture)
	if !mapdata.is_in_bounds(Grid.world_to_grid(get_global_mouse_position())):
		can_place = false
		#print("can't plcae")
		mouse_coords.emit("ERROR OUT OF BOUNDS")
	else:
		mouse_coords.emit("grid_position(x:"+mx+" y:"+my+")")
		if !hidden:
			can_place = true
	match current_state:
		EDITOR_MODE.DRAWING:
			if current_item!=null:
				modulate = current_item.color
			if current_tile!=null:
				modulate = current_tile.color_lit.duplicate().pop_front()
			if (current_tile !=null and can_place == true and Input.is_action_just_pressed("mb_click")):
				print("MOUSE ROUNDED",global_position,"MOUSE TO GRID",Grid.world_to_grid(global_position))
				var tile:Tile = mapdata.get_tile(Grid.world_to_grid(global_position))
				if tile ==null:
					tile = Tile.new(Grid.world_to_grid(global_position),current_tile.name.to_lower())
				else:
					tile.set_tile_type(current_tile.name)
			if current_item !=null and can_place and Input.is_action_just_pressed("mb_click"):
				var new_item = Entity
				new_item = Entity.new(mapdata,mouse_checker_tile._mouse_tile,current_item.name.to_lower())
				mapdata.entities.append(new_item)
				level.add_child(new_item)
				
		EDITOR_MODE.ERASING:
			if can_place and Input.is_action_just_pressed("mb_click"):
				var tile:Tile = mapdata.get_tile(mouse_checker_tile._mouse_tile)
				var entity:Entity = mapdata.get_actor_at_location(mouse_checker_tile._mouse_tile)
				if entity!=null:
					print("ENETIY",entity.grid_position,"TILE",tile.grid_position)
					print(entity.name)
					entity.map_data.entities.erase(entity)
					entity.queue_free()
				else:
					tile.set_tile_type("blank")
	if editor_cam.is_current():
		move_editor()
	is_panning = Input.is_action_pressed("mb_middle")
	pass

func move_editor():
	if Input.is_action_pressed("W"):
		print("move")
		editor.global_position.y -=cam_spd
	if Input.is_action_pressed("A"):
		editor.global_position.x -=cam_spd
	if Input.is_action_pressed("S"):
		editor.global_position.y +=cam_spd
	if Input.is_action_pressed("D"):
		editor.global_position.x +=cam_spd
	pass
##this function is in charge of showing off if you can interact or not
func canplacetexture(texture:Texture):
	if texture == null:
		texture = notexture
	%"canplace".texture = texture
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				editor_cam.zoom -= Vector2(0.1,0.1)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				editor_cam.zoom -= Vector2(-0.1,-0.1)
	if event is InputEventMouseMotion:
		if is_panning:
			editor.global_position -= event.relative *editor_cam.zoom
func _on_check_button_toggled(button_pressed):
	if editor_cam.is_current():
		player_cam.make_current()
	elif player_cam.is_current():
		editor_cam.global_position = player_cam.global_position
		editor_cam.make_current()
	pass # Replace with function body.
	


func _on_drawmode_pressed():
	current_state = EDITOR_MODE.DRAWING
	pass # Replace with function body.


func _on_erasemode_pressed():
	current_state = EDITOR_MODE.ERASING
	current_item = null
	current_tile = null
	modulate = Color.RED
	$Sprite.texture = erase_tool
	pass # Replace with function body.
