extends Node2D

var can_place = true
var is_panning = true
var cam_spd = 10
@onready var level:Node2D =%"Game"/Map/Entities
@onready var editor:Node2D = %"cameracontainer"
@onready var editor_cam:Camera2D = %"editorcam"
var current_item:EntityDefinition
@onready var player_cam:Camera2D = %"Camera2D"

func _ready():
	pass


func _process(delta):
	global_position = get_global_mouse_position()
	global_position.x = ((round(global_position.x / 16)) * 16)
	global_position.y = ((round(global_position.y / 16)) * 16)
	
	if current_item!=null:
		modulate = current_item.color
	if (current_item !=null and can_place and Input.is_action_just_pressed("mb_click")):
		var new_item = Entity
		var map:Map = level.get_parent()
		var mapdata:MapData = map.map_data
		new_item = Entity.new(mapdata,Grid.world_to_grid(get_global_mouse_position()),current_item.name.to_lower())
		mapdata.entities.append(new_item)
		level.add_child(new_item)
		new_item.global_position = get_global_mouse_position()
		new_item.global_position.x = ((round(global_position.x / 16)) * 16)
		new_item.global_position.y = ((round(global_position.y / 16)) * 16)
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
	
