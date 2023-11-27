class_name MeleeAction
extends ActionWithDirection
func perform() -> bool:
	randomize()
	var target_entity: Entity = get_target_actor()
	var target_tile: Tile = get_target_tile()
	var attacker_stat:FighterComponent = entity.fighter_component
	var defender_stat:FighterComponent
	var attacking_limb
	var dice:Array[int]
	var hit_roll
	var hit: int
	var damroll: int
	var damage: int
	var attack_color: Color
	var crit:Color = GameColors.CRIT
	var attack_description:String
	if target_entity == null and target_tile== null:
		return false
	if target_entity!=null:
		if target_entity.fighter_component:
			defender_stat= target_entity.fighter_component
		if not target_entity:
			if entity == get_map_data().player:
				MessageLog.send_message("Nothing to attack.", GameColors.IMPOSSIBLE)
			return false
		
		if entity == get_map_data().player:
			attack_color = GameColors.PLAYER_ATTACK
		else:
			attack_color = GameColors.ENEMY_ATTACK
		if attacker_stat.base_offhand_attack_chance >0:
			var offhand_roll:int
			var offhandlimbs:Array[Limb_Component] = attacker_stat.offhand_limbs.duplicate()
			while !offhandlimbs.is_empty():
				randomize()
				offhand_roll = entity.dicebag.roll_dice(1,100)
				var get_currentlimb:Limb_Component  = offhandlimbs.pop_front()
				if offhand_roll> attacker_stat.base_offhand_attack_chance:
					continue
				if attacker_stat.current_primary_limb.equiped_item_definition!=null:
					dice = attacker_stat.current_primary_limb.equiped_item_definition.equipment_item_component.damage_dice.duplicate()
				else:
					dice = attacker_stat.current_primary_limb.damage_dice.duplicate()
				hit_roll = entity.dicebag.roll_dice(1,20,attacker_stat.critdam)
				damroll = entity.dicebag.roll_dice(dice.pop_front(),dice.pop_front())
				hit= hit_roll+entity.fighter_component.hit_chance
				damage= damroll - defender_stat.defense
				if get_currentlimb.equiped_item != null:
					attack_description = "%s attacks %s with their %s" %[entity.get_entity_name(),target_entity.get_entity_name(),get_currentlimb.equiped_item.get_entity_name()]
				else:
					attack_description = "%s attacks %s with their %s" %[entity.get_entity_name(),target_entity.get_entity_name(),get_currentlimb.name_limb]
				if hit_roll>=20:
					damage*=2
				elif hit <defender_stat.DV:
					attack_description+= " but misses!!"
					MessageLog.send_message(attack_description, attack_color)
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
				if hit_roll >=20:
					attack_description+=" CRIT!!!!!!!!!!!!!!"
					defender_stat.take_damage(damage,DamageTypes.DAMAGE_TYPES.BLUDGEONING,attack_description)
				else:
					if dismember_chance>=21:
						defender_stat.body_plan.dismember(attacker_stat.decap)
					defender_stat.take_damage(damage,DamageTypes.DAMAGE_TYPES.BLUDGEONING,attack_description)
				return true
		if attacker_stat.current_primary_limb.equiped_item_definition!=null:
			dice = attacker_stat.current_primary_limb.equiped_item_definition.equipment_item_component.damage_dice.duplicate()
		else:
			dice = attacker_stat.current_primary_limb.damage_dice.duplicate()
		hit_roll = entity.dicebag.roll_dice(1,20,attacker_stat.critdam)
		damroll = entity.dicebag.roll_dice(dice.pop_front(),dice.pop_front())
		hit= hit_roll+entity.fighter_component.hit_chance
		damage= damroll - defender_stat.defense
		if attacker_stat.current_primary_limb.equiped_item_definition != null:
			attack_description = "%s attacks %s with their %s" %[entity.get_entity_name(),target_entity.get_entity_name(),attacker_stat.current_primary_limb.equiped_item_definition.name]
		else:
			attack_description = "%s attacks %s with their %s" %[entity.get_entity_name(),target_entity.get_entity_name(),attacker_stat.current_primary_limb.name_limb]
		if hit_roll>=20:
			damage*=2
		elif hit <defender_stat.DV:
			attack_description+= " but misses!!"
			MessageLog.send_message(attack_description, attack_color)
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
		if hit_roll >=20:
			attack_description+=" CRIT!!!!!!!!!!!!!!"
			defender_stat.take_damage(damage,DamageTypes.DAMAGE_TYPES.BLUDGEONING,attack_description)
		else:
			if dismember_chance>=21:
				defender_stat.body_plan.dismember(attacker_stat.decap)
			defender_stat.take_damage(damage,DamageTypes.DAMAGE_TYPES.BLUDGEONING,attack_description)
		return true
	elif target_tile!=null:
		if not target_tile:
			if entity == get_map_data().player:
				if entity.map_data.get_tile(entity.map_data.player.grid_position).is_in_view:
					MessageLog.send_message("Nothing to attack.", GameColors.IMPOSSIBLE)
			return false
		if entity == get_map_data().player:
			attack_color = GameColors.PLAYER_ATTACK
		else:
			attack_color = GameColors.ENEMY_ATTACK
		crit = GameColors.CRIT
		attack_description= "%s attacks %s" % [entity.get_entity_name(), target_tile.tile_name]
		if hit_roll>=20:
			damage*=2
		elif hit <target_tile.DV:
			attack_description+= " but misses!!"
			if entity.map_data.get_tile(entity.map_data.player.grid_position).is_in_view:
				MessageLog.send_message(attack_description, attack_color,entity)
			return true
		if damage > 0:
			if hit_roll >=20:
				attack_description+=" CRIT!!!!!!!!!!!!!!"
				attack_description += " for %d hit points." % damage
				if entity.map_data.get_tile(entity.map_data.player.grid_position).is_in_view:
					MessageLog.send_message(attack_description, crit,entity)
				
				target_tile.hp -= damage
			else:
				
				attack_description += " for %d hit points." % damage
				if entity.map_data.get_tile(entity.map_data.player.grid_position).is_in_view:
					MessageLog.send_message(attack_description, attack_color,entity)
				target_tile.hp -= damage
		else:
			attack_description += " but does no damage..."
			if entity.map_data.get_tile(entity.map_data.player.grid_position).is_in_view:
				MessageLog.send_message(attack_description, attack_color,entity)
		return true
	else:
		return false
