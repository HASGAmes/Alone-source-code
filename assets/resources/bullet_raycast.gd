extends RayCast2D

var grid_position: Vector2i:
	set(value):
		grid_position = value
		global_position = Grid.grid_to_world(grid_position)
