class_name HostStatus
extends StatusBase
var can_spawn:int = 0
var turns:int = 0
var host:EntityDefinition
var silent_host
func _init(status:HostDefinition) -> void:
	host = status.host
	silent_host = status.silenthost
	pass
func activate_effect(entity:Entity) -> void:
	if entity.fighter_component.aggression !=21:
		if silent_host == false:
			entity.modulate = Color(0.741, 0.176, 0.176)
			entity.entity_name = "infected "+ entity.entity_name
		entity.fighter_component.aggression = 21
		#print(entity.ai_component.aggression)
	var roll = true
	match entity.type:
		Entity.EntityType.CORPSE:
			turns+=1
			roll = entity.fighter_component._save_roll(10,entity.fighter_component.toughness_mod)
			if roll == false and turns>2:
				turns= 0
				MessageLog.send_message("The %s twitch" % entity.get_entity_name(),GameColors.ENEMY_DIE)
				can_spawn+=1
			elif roll == true and turns>2:
				turns= 0
				MessageLog.send_message("The %s lay there motionless" % entity.get_entity_name(),GameColors.ENEMY_DIE)
	if can_spawn>=3:
		var new_entity: Entity
		new_entity = Entity.new(entity.map_data, entity.grid_position ,host)
		var parent = entity.get_parent()
		entity.map_data.entities.append(new_entity)
		parent.add_child(new_entity)
		MessageLog.send_message("The host came swirming from the corpse!!!!",GameColors.CRIT)
		queue_free()
	pass

