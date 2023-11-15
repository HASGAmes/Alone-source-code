class_name TurretAi
extends BaseAIComponent


var path: Array = []
var attacking_actor:Entity
var list_of_friendlys:Array[Entity]
func perform() -> void:
	var target: Entity = get_map_data().player
	var target_grid_position: Vector2i = target.grid_position
	var offset: Vector2i = target_grid_position - entity.grid_position
	var distance: int = max(abs(offset.x), abs(offset.y))
	attacking_actor = target
	var ranged_weapon:Array[Entity] = entity.fighter_component.get_weapon(entity,entity.equipment_item_component.WEAPON_TYPES.LONGGUN).duplicate()
	var weapon_stats
	if !ranged_weapon.is_empty():
		var current_weapon = ranged_weapon.pop_front()
		weapon_stats = current_weapon.equipment_item_component
		print(weapon_stats)
	if get_map_data().get_tile(entity.grid_position).is_in_view:
		if distance >= 1 and weapon_stats!=null:
			print("should work")
			return RangedAction.new(entity,offset,weapon_stats.damage_dice,weapon_stats.bullets,weapon_stats.spread).perform()
		
		path = get_point_path_to(target_grid_position)
		path.pop_front()
	
#	if not path.is_empty():
#		var destination := Vector2i(path.pop_front())
#		var move_offset: Vector2i = destination - entity.grid_position
#		return MovementAction.new(entity, move_offset.x, move_offset.y).perform()
	
	return WaitAction.new(entity).perform()
