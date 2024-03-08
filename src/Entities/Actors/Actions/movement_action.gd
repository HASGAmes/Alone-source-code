class_name MovementAction
extends ActionWithDirection


func perform() -> bool:
	var destination: Vector2i = get_destination()
	var map_data: MapData = get_map_data()
	var multi_tile_destination:Array[Vector2i] = get_multi_tile_destination()
	var destination_tile: Tile = map_data.get_tile(destination)
#	if entity.MOVEMENT_TYPE.CROUCH:
#		entity.MOVEMENT_TYPE.WALK
#		return false
	
	if entity.current_movement==entity.MOVEMENT_TYPE.PRONE:
		entity.current_movement=entity.MOVEMENT_TYPE.WALK
		return true
	
	if entity.entity_size>Vector2i(1,1):
		var pos = multi_tile_destination.duplicate()
		#print(pos)
		while !pos.is_empty():
			var current = pos.pop_front()
			#print(current,"dest")
			var tile = map_data.get_tile(current)
			var blockingactor = map_data.get_actor_at_location(current)
			#print(tile.grid_position)
			if blockingactor !=null:
				if entity == get_map_data().player:
					var actor = blockingactor
					if actor.current_movement == entity.MOVEMENT_TYPE.PRONE:
						MessageLog.send_message("%s cannot be moved"%actor.get_entity_name(), GameColors.IMPOSSIBLE)
						return false
					else:
						entity.swap(actor)
						return true
					MessageLog.send_message("That way is blocked.", GameColors.IMPOSSIBLE)
					return false
			if !tile.is_walkable():
				MessageLog.send_message("That way is blocked.", GameColors.IMPOSSIBLE)
				return false
		print(entity.name,offset)
		entity.move(offset)
		return true
	
	if get_blocking_entity_at_destination():
		if entity == get_map_data().player:
			var actor = map_data.get_actor_at_location(destination)
			if actor.current_movement == entity.MOVEMENT_TYPE.PRONE:
				MessageLog.send_message("%s cannot be moved"%actor.get_entity_name(), GameColors.IMPOSSIBLE)
				return false
			else:
				entity.swap(actor)
				return true
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
	if not destination_tile.is_walkable():
		MessageLog.send_message("That way is blocked.", GameColors.IMPOSSIBLE)
		return false 
	else:
		print(entity.name,offset)
		entity.move(offset)
		return true

