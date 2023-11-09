class_name HostStatus
extends StatusBase
var can_spawn:int = 0
var turns:int = 0
var host:EntityDefinition
var silent_host
var statusname:String
var forever:bool
var definition
var stack:bool
func _init(status:HostDefinition) -> void:
	host = status.host
	silent_host = status.silenthost
	definition = status.duplicate()
	stack = status.can_stack
	#turns = definition.turns
	pass
func activate_effect(entity:Entity) -> void:
	var screen :CanvasModulate
	screen = entity.get_parent().get_parent().screeneffects
	if entity.fighter_component.aggression !=200:
		
		if silent_host == false:
			entity.modulate = Color(0.741, 0.176, 0.176)
			entity.entity_name = "infected "+ entity.entity_name
		entity.fighter_component.aggression = 200
		#print(entity.ai_component.aggression)
	var roll = true
	if entity.map_data.player == entity:
		screen.color = Color.BROWN
		roll = entity.fighter_component._save_roll(10,entity.fighter_component.toughness_mod)
		turns+=1
		if roll == false and turns>2:
			turns= 0
			if can_spawn == 0:
				
				MessageLog.send_message("You feel something crawling inside you" ,GameColors.ENEMY_DIE)
			if can_spawn ==1:
				MessageLog.send_message("You want to scream.... it hurts" ,GameColors.ENEMY_DIE)
			if can_spawn == 2:
				MessageLog.send_message("You feel like you are about to burst!!!",GameColors.ENEMY_DIE)
			can_spawn+=1
		elif roll == true and turns>2:
			turns= 0
			MessageLog.send_message("Your body resists",GameColors.ENEMY_DIE)
			can_spawn -= 1
	elif !entity.is_alive():
		turns+=1
		if entity.consumable_component!= null:
			definition.proc_chance = 50
			entity.consumable_component.food_buff = definition.duplicate()
		roll = entity.fighter_component._save_roll(5,entity.fighter_component.toughness_mod)
		if roll == false and turns>2:
			turns= 0
			MessageLog.send_message("The %s twitch" % entity.get_entity_name(),GameColors.ENEMY_DIE)
			can_spawn+=1
		elif roll == true and turns>2:
			turns= 0
			can_spawn -= 1
			MessageLog.send_message("The %s lay there motionless" % entity.get_entity_name(),GameColors.ENEMY_DIE)
	if can_spawn == -2 or host == null:
		entity.modulate = entity._definition.color
		if entity.map_data.player == entity:
			screen.color = Color.WHITE
			MessageLog.send_message("Your body managed to survive its intruder",GameColors.STATUS_END)
		else:
			MessageLog.send_message("The parasite dies in %s"%entity.get_entity_name(),GameColors.STATUS_END)
		queue_free()
	if can_spawn>=3:
		screen.modulate = Color(1,1,1)
		var new_entity: Entity
		new_entity = Entity.new(entity.map_data, entity.grid_position ,host)
		var parent = entity.get_parent()
		entity.map_data.entities.append(new_entity)
		parent.add_child(new_entity)
		entity.fighter_component.body_plan.dismember(false)
		MessageLog.send_message("The host came swirming from the %s!!!!"% entity.get_entity_name(),GameColors.CRIT)
		queue_free()
	pass

