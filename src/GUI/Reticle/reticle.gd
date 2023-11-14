class_name Reticle
extends Node2D

signal position_selected(grid_position)

const directions = {
	"move_up": Vector2i.UP,
	"move_down": Vector2i.DOWN,
	"move_left": Vector2i.LEFT,
	"move_right": Vector2i.RIGHT,
	"move_up_left": Vector2i.UP + Vector2i.LEFT,
	"move_up_right": Vector2i.UP + Vector2i.RIGHT,
	"move_down_left": Vector2i.DOWN + Vector2i.LEFT,
	"move_down_right": Vector2i.DOWN + Vector2i.RIGHT,
}

var grid_position: Vector2i:
	set(value):
		grid_position = value
		position = Grid.grid_to_world(grid_position)
var free_move:bool = false
var map_data: MapData
var stay_in_range:bool
var return_offset:bool
@onready var camera: Camera2D = $Camera2D
@onready var border: Line2D = $Line2D
var border_position:Vector2i:
	set(value):
		border_position = value
		border.position = Grid.grid_to_world(border_position)
var pressed= null
var org_pos:Vector2
var player_pos
var total_offset:Vector2i = Vector2i.ZERO
func _ready() -> void:
	hide()
	set_physics_process(false)


func select_position(player: Entity, radius: int,freemove:bool,stay_in_range:bool = false,return_offset:bool = false) -> Vector2i:
	map_data = player.map_data
	grid_position = player.grid_position
	org_pos = border.position
	self.free_move = freemove
	self.stay_in_range = stay_in_range
	self.return_offset = return_offset
	var player_camera: Camera2D = get_viewport().get_camera_2d()
	camera.make_current()
	camera.position_smoothing_enabled = false
	camera.position_smoothing_speed = 6
	_setup_border(radius)
	show()
	await get_tree().physics_frame
	set_physics_process.call_deferred(true)
	
	var selected_position: Vector2i = await position_selected
	
	set_physics_process(false)
	player_camera.make_current()
	hide()
	border.position = org_pos
	border_position = Grid.world_to_grid(org_pos)
	return selected_position


func _physics_process(delta: float) -> void:
	var offset := Vector2i.ZERO
	
	if $input_delay.is_stopped():
		for direction in directions:
			if Input.is_action_just_pressed(direction):
				pressed = true
				if Input.is_action_pressed(direction) and pressed == true:
					print_rich(direction)
					offset += directions[direction]
					
					grid_position += offset
					total_offset+=offset
					$input_delay.start()
					if free_move == false:
						
						position_selected.emit(offset)
					elif stay_in_range ==true:
						border_position -= offset
	for direction in directions:
		if Input.is_action_just_released(direction):
			pressed = null
			$input_delay.stop()
	if Input.is_action_just_pressed("ui_accept"):
		border_position = grid_position
		if return_offset == true:
			grid_position =total_offset
			total_offset = Vector2i.ZERO
		position_selected.emit(grid_position)
		
	if Input.is_action_just_pressed("ui_back"):
		border_position = grid_position
		position_selected.emit(Vector2i.ZERO)


func _setup_border(radius: int) -> void:
	if radius <= 0:
		border.hide()
	else:
		border.points = [
			Vector2i(-radius, -radius) * Grid.tile_size,
			Vector2i(-radius, radius + 1) * Grid.tile_size,
			Vector2i(radius + 1, radius + 1) * Grid.tile_size,
			Vector2i(radius + 1, -radius) * Grid.tile_size,
			Vector2i(-radius, -radius) * Grid.tile_size
		]
		border.show()


func _on_input_delay_timeout():
	pass # Replace with function body.
