class_name JumpSkill
extends Skills
var cooldown
var range
var skill_name
var map :MapData
var tick_cooldown:int
var free_move
var skill_buff
func _init(definition:JumpDefinition):
	cooldown = definition.skill_cooldown
	range = definition.skill_range
	tick_cooldown = cooldown
	self.free_move = definition.free_move
	skill_name= definition.skill_name
	self.skill_buff =definition.skill_buff
func activate(user:Entity,action: SkillAction,target_position:Vector2i,mapdata:MapData) -> bool:
	map = user.map_data
	
	if tick_cooldown == cooldown:
		var firsttile:Tile = map.get_tile(user.grid_position)
		var secondtile:Tile = map.get_tile(target_position)
		var distance =firsttile.distance(secondtile.grid_position)
		if distance>range+user.fighter_component.strength_mod:
			print(range,-range)
			MessageLog.send_message("Target out of range",GameColors.INVALID)
			return false
		if !secondtile.is_in_view:
			MessageLog.send_message("Target not in view",GameColors.INVALID)
			return false
		if !secondtile.is_walkable():
			MessageLog.send_message("Target cannot be jumped on",GameColors.INVALID)
			return false
		if map.get_blocking_entity_at_location(target_position):
			MessageLog.send_message("Cannot jump on %s"%map.get_blocking_entity_at_location(target_position).get_entity_name(),GameColors.INVALID)
			return false
		
		else:
			MessageLog.send_message("The %s jumps"%user.get_entity_name(),GameColors.PLAYER_ATTACK)
			user.grid_position = target_position
			tick_cooldown = 0
			return true
	else:
		MessageLog.send_message("Skill not off cooldown",GameColors.INVALID)
		return false
