class_name MeleeAction
extends ActionWithDirection


func perform() -> bool:
	randomize()
	var target_entity: Entity = get_target_actor()
	var target_tile: Tile = get_target_tile()
	var attacker_stat = entity.fighter_component
	var defender_stat
	var attacking_limb
	
	if target_entity == null and target_tile== null:
		return false
	if target_entity!=null:
		if target_entity.fighter_component:
			defender_stat= target_entity.fighter_component
		if not target_entity:
			if entity == get_map_data().player:
				MessageLog.send_message("Nothing to attack.", GameColors.IMPOSSIBLE)
			return false
		var hit_roll = entity.dicebag.roll_dice(1,20,attacker_stat.critdam)
		var damroll: int = entity.dicebag.roll_dice(1,attacker_stat.power,attacker_stat.str)
		var hit: int = hit_roll+entity.fighter_component.hit_chance
		var damage: int = damroll - defender_stat.defense
		var attack_color: Color
		var crit:Color
		if entity == get_map_data().player:
			attack_color = GameColors.PLAYER_ATTACK
		else:
			attack_color = GameColors.ENEMY_ATTACK
		crit = GameColors.CRIT
		var attack_description: String = "%s attacks %s" % [entity.get_entity_name(), target_entity.get_entity_name()]
		if hit_roll>=20:
			damage=attacker_stat.power*2
		elif hit <defender_stat.DV:
			attack_description+= " but misses!!"
			MessageLog.send_message(attack_description, attack_color)
			return true
		if damage > 0:
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
				attack_description += " for %d hit points." % damage
				if entity.map_data.get_tile(entity.map_data.player.grid_position).is_in_view:
					MessageLog.send_message(attack_description, crit)
				var knockbackvec = entity.grid_position - target_entity.grid_position
				target_entity.knockback(knockbackvec,attacker_stat.strength_mod)
				defender_stat.hp -= damage
			else:
				if dismember_chance>=21:
					defender_stat.body_plan.dismember(attacker_stat.decap)
				attack_description += " for %d hit points." % damage
				if entity.map_data.get_tile(entity.map_data.player.grid_position).is_in_view:
					MessageLog.send_message(attack_description, attack_color)
				defender_stat.hp -= damage
		else:
			attack_description += " but does no damage..."
			MessageLog.send_message(attack_description, attack_color)
		return true
	elif target_tile!=null:
		if not target_tile:
			if entity == get_map_data().player:
				if entity.map_data.get_tile(entity.map_data.player.grid_position).is_in_view:
					MessageLog.send_message("Nothing to attack.", GameColors.IMPOSSIBLE)
			return false
		var hit_roll = entity.dicebag.roll_dice(1,20,attacker_stat.critdam)
		var damroll: int = entity.dicebag.roll_dice(1,attacker_stat.power,attacker_stat.str)
		var hit: int = hit_roll+entity.fighter_component.hit_chance
		var damage: int = damroll - target_tile.defense
		var attack_color: Color
		var crit:Color
		if entity == get_map_data().player:
			attack_color = GameColors.PLAYER_ATTACK
		else:
			attack_color = GameColors.ENEMY_ATTACK
		crit = GameColors.CRIT
		var attack_description: String = "%s attacks %s" % [entity.get_entity_name(), target_tile.tile_name]
		if hit_roll>=20:
			damage=attacker_stat.power*2
		elif hit <target_tile.DV:
			attack_description+= " but misses!!"
			if entity.map_data.get_tile(entity.map_data.player.grid_position).is_in_view:
				MessageLog.send_message(attack_description, attack_color)
			return true
		if damage > 0:
			
			
			if hit_roll >=20:
				attack_description+=" CRIT!!!!!!!!!!!!!!"
				attack_description += " for %d hit points." % damage
				if entity.map_data.get_tile(entity.map_data.player.grid_position).is_in_view:
					MessageLog.send_message(attack_description, crit)
				
				target_tile.hp -= damage
			else:
				
				attack_description += " for %d hit points." % damage
				if entity.map_data.get_tile(entity.map_data.player.grid_position).is_in_view:
					MessageLog.send_message(attack_description, attack_color)
				target_tile.hp -= damage
		else:
			attack_description += " but does no damage..."
			if entity.map_data.get_tile(entity.map_data.player.grid_position).is_in_view:
				MessageLog.send_message(attack_description, attack_color)
		return true
	else:
		return false
