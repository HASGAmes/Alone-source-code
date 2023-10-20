class_name FireballDamageConsumableComponent
extends ConsumableComponent

var damage: int
var radius: int
var audio
func _init(definition: FireballDamageConsumableComponentDefinition):
	damage = definition.damage
	radius = definition.radius
	audio = definition


func activate(action: ItemAction) -> bool:
	var target_position: Vector2i = action.target_position
	var map_data: MapData = get_map_data()
	randomize()
	if not map_data.get_tile(target_position).is_in_view:
		MessageLog.send_message("You cannot target an area that you cannot see.", GameColors.IMPOSSIBLE)
		return false
	
	var targets := []
	for actor in map_data.get_actors():
		if actor.distance(target_position) <= radius:
			targets.append(actor)
	
#	if targets.is_empty():
#		MessageLog.send_message("There are no targets in the radius.", GameColors.IMPOSSIBLE)
#		return false
#	if targets.size() == 1 and targets[0] == map_data.player:
#		MessageLog.send_message("There are not enemy targets in the radius.", GameColors.IMPOSSIBLE)
#		return false
	
	play_sound(audio)
	for target in targets:
#		if get_map_data().player == target:
		if target.type != Entity.EntityType.CORPSE:
			var damroll = target.dicebag.roll_dice(2,damage,-target.fighter_component.defense)
			damage = damroll
			if damage<=0:
				MessageLog.send_message("The %s is engulfed in a fiery explosion, but is unharmed!?!" % [target.get_entity_name()], GameColors.CRIT)
			else:
				MessageLog.send_message("The %s is engulfed in a fiery explosion, taking %d damage!" % [target.get_entity_name(), damage], GameColors.CRIT)
				target.fighter_component.take_damage(target.fighter_component.max_hp)
				if target_position !=target.grid_position:
					var knockbackvec = target_position - target.grid_position
					target.knockback(knockbackvec,damage)
				target.fighter_component.body_plan.dismember(true)
	var tile_targets := []
	for tile in map_data.get_tiles():
		if tile.distance(target_position) <= radius:
			tile_targets.append(tile)
	for tile in tile_targets:
		tile.hp -=damage
		MessageLog.send_message("The %s blown to bits, taking %d damage!" % [tile.tile_name, damage], GameColors.CRIT)
	consume(action.entity)
	return true


func get_targeting_radius() -> int:
	return radius
