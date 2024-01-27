class_name MeleeAction
extends ActionWithDirection
var attacking_limb
var dice:Array[int]
var hit_roll
var hit: int
var damroll: int
var damage: int
var attack_color: Color
var crit:Color = GameColors.CRIT
var attack_description:String
var current_damagetypes:DamageTypes.DAMAGE_TYPES

func perform() -> bool:
	randomize()
	var target_entity: Entity = get_target_actor()
	var target_tile: Tile = get_target_tile()
	var attacker_stat:FighterComponent = entity.fighter_component
	var defender_stat:FighterComponent
	
	if target_entity == null and target_tile== null:
		return false
	if entity == get_map_data().player:
			attack_color = GameColors.PLAYER_ATTACK
	else:
		attack_color = GameColors.ENEMY_ATTACK
	if target_entity!=null:
		if target_entity.fighter_component:
			defender_stat= target_entity.fighter_component
		if not target_entity:
			if entity == get_map_data().player:
				MessageLog.send_message("Nothing to attack.", GameColors.IMPOSSIBLE)
			return false
		if attacker_stat.base_offhand_attack_chance >0:
			var offhand_roll:int
			var offhandlimbs:Array[Limb_Component] = attacker_stat.offhand_limbs.duplicate()
			while !offhandlimbs.is_empty():
				randomize()
				offhand_roll = entity.dicebag.roll_dice(1,100)
				var get_currentlimb:Limb_Component  = offhandlimbs.pop_front()
				if offhand_roll> attacker_stat.base_offhand_attack_chance:
					continue
				handle_hit_chance_and_damage(attacker_stat,get_currentlimb,defender_stat)
				attacker_stat.turns_not_in_combat = 0
				defender_stat.credit_exp = entity
				if target_entity.ai_component is PredatorAi and !target_entity == self:
					target_entity.ai_component.attacking_actor = entity
				if target_entity.ai_component is PreyAi and !target_entity == self:
					target_entity.ai_component.attacking_actor = entity
				var dismember_chance = target_entity.dicebag.roll_dice(1,20,attacker_stat.dismember_chance)
				if !attacker_stat.onhit_effects.is_empty():
					for StatusEffectDefinition in attacker_stat.onhit_effects:
						var proc = randi_range(1,100)
						if proc <= StatusEffectDefinition.proc_chance:
							target_entity.add_status(attacker_stat.onhit_effects.duplicate())
				if dismember_chance>=21:
					defender_stat.body_plan.dismember(attacker_stat.decap)
				return true
			
		if attacker_stat.current_primary_limb.equiped_item!=null:
			dice = attacker_stat.current_primary_limb.equiped_item.equipment_item_component.damage_dice.duplicate()
		else:
			dice = attacker_stat.current_primary_limb.damage_dice.duplicate()
		var check_hit = handle_hit_chance_and_damage(attacker_stat,attacker_stat.current_primary_limb,defender_stat)
		if check_hit == false:
			return true
		attacker_stat.turns_not_in_combat = 0
		defender_stat.credit_exp = entity
		if target_entity.ai_component is PredatorAi and !target_entity == self:
			target_entity.ai_component.attacking_actor = entity
		if target_entity.ai_component is PreyAi and !target_entity == self:
			target_entity.ai_component.attacking_actor = entity
		var dismember_chance = target_entity.dicebag.roll_dice(1,20,attacker_stat.dismember_chance)
		if !attacker_stat.onhit_effects.is_empty():
			for StatusEffectDefinition in attacker_stat.onhit_effects:
				var proc = randi_range(1,100)
				if proc <= StatusEffectDefinition.proc_chance:
					target_entity.add_status(attacker_stat.onhit_effects.duplicate())
		else:
			if dismember_chance>=21:
				defender_stat.body_plan.dismember(attacker_stat.decap)
		return true
	elif target_tile!=null:
		if not target_tile:
			if entity == get_map_data().player:
				if entity.map_data.get_tile(entity.map_data.player.grid_position).is_in_view:
					MessageLog.send_message("Nothing to attack.", GameColors.IMPOSSIBLE)
			return false
		var checkhit = handle_hit_chance_and_damage(attacker_stat,attacker_stat.current_primary_limb,null,target_tile)
		return true
	return true
func handle_hit_chance_and_damage(attacker:FighterComponent,currentlimb:Limb_Component,defender:FighterComponent=null,tile:Tile = null)->bool:
	randomize()
	hit_roll = entity.dicebag.roll_dice(1,20,attacker.critdam)
	hit= hit_roll+entity.fighter_component.hit_chance
	var attackednamestring
	print(damage,"damage")
	if defender!=null:
		attackednamestring = defender.entity.get_entity_name()
	print(attacker.entity.get_entity_name(),currentlimb.equiped_item)
	if currentlimb.equiped_item != null:
		current_damagetypes = currentlimb.equiped_item.equipment_item_component.current_damagetypes
		attack_description = "%s attacks %s with their %s" %[attacker.entity.get_entity_name(),attackednamestring,attacker.current_primary_limb.equiped_item.get_entity_name()]
		var dice =currentlimb.equiped_item.equipment_item_component.damage_dice.duplicate()
		print(dice)
		damroll = entity.dicebag.roll_dice(dice.pop_front(),dice.pop_front())
	else:
		current_damagetypes = currentlimb.current_damagetypes
		attack_description = "%s attacks %s with their %s" %[attacker.entity.get_entity_name(),attackednamestring,attacker.current_primary_limb.name_limb]
		var dice = currentlimb.damage_dice.duplicate()
		damroll = entity.dicebag.roll_dice(dice.pop_front(),dice.pop_front())
	damage = damroll
	if tile!=null:
		attackednamestring = tile.tile_name
		if attacker.current_primary_limb.equiped_item != null:
			attack_description = "%s attacks %s with their %s" %[attacker.entity.get_entity_name(),tile.tile_name,attacker.current_primary_limb.equiped_item.get_entity_name()]
		else:
			attack_description = "%s attacks %s with their %s" %[attacker.entity.get_entity_name(),tile.tile_name,attacker.current_primary_limb.name_limb]
		if hit_roll>=20:
			damage*=2
			SignalBus.critted.emit(entity)
		if tile.defense>=damage:
			attack_description += " but does no damage..."
			MessageLog.send_message(attack_description, attack_color,entity)
			return false
		else:
			attack_description += " for %d hit points." % damage
			MessageLog.send_message(attack_description, attack_color,entity)
			tile.hp -= damage
			return true
	if defender!=null:
		if hit <defender.DV:
			attack_description+= " but misses!!"
			SignalBus.missed.emit(entity)
			MessageLog.send_message(attack_description, attack_color)
			return false
		damage -= defender.defense
		defender.take_damage(damage,current_damagetypes,attack_description)
	SignalBus.attacked.emit(entity)
	return true
