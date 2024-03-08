class_name ActionWithDirection
extends Action

var offset: Vector2i


func _init(entity: Entity, dx: int, dy: int) -> void:
	super._init(entity)
	offset = Vector2i(dx, dy)


func get_destination() -> Vector2i:
	return entity.grid_position + offset
func get_multi_tile_destination() -> Array[Vector2i]:
	entity.set_size(entity.texture_size)
	var copy1= entity.size_points.duplicate()
	var copy2:Array[Vector2i]
	while !copy1.is_empty():
		var current = copy1.pop_front()
		current+= offset
		copy2.append(current)
	
	return copy2

func get_blocking_entity_at_destination() -> Entity:
	return get_map_data().get_blocking_entity_at_location(get_destination())


func get_target_actor() -> Entity:
	return get_map_data().get_actor_at_location(get_destination())
	
func get_target_tile() -> Tile:
	return get_map_data().get_tile(get_destination())
