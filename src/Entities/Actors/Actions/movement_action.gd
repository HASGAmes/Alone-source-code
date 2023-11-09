class_name MovementAction
extends ActionWithDirection


func perform() -> bool:
	var destination: Vector2i = get_destination()
	
	var map_data: MapData = get_map_data()
	var destination_tile: Tile = map_data.get_tile(destination)
#	if entity.MOVEMENT_TYPE.CROUCH:
#		entity.MOVEMENT_TYPE.WALK
#		return false
	if entity.current_movement==entity.MOVEMENT_TYPE.PRONE:
		return true
	if map_data.get_actor_at_location(destination) and entity == get_map_data().player:
		var actor = map_data.get_actor_at_location(destination)
		entity.swap(actor)
		return true
	if not destination_tile or not destination_tile.is_walkable() or get_blocking_entity_at_destination():
		if entity == get_map_data().player:
			MessageLog.send_message("That way is blocked.", GameColors.IMPOSSIBLE)
		return false
	if destination_tile.terrain_effect != null:
		var proc = randi_range(1,100)
		if proc <= destination_tile.terrain_effect.proc_chance:
			var status :Array [StatusEffectDefinition]
			status = [destination_tile.terrain_effect]
			entity.add_status(status)
	if destination_tile.is_slippery():
		var save =entity.fighter_component._save_roll(5,entity.fighter_component.dex_mod)
		if save == false:
			MessageLog.send_message("%s slips and goes prone"% entity.get_entity_name(),GameColors.ENEMY_ATTACK)
			entity.current_movement = entity.MOVEMENT_TYPE.PRONE
			return true
	entity.move(offset)
	return true
	
