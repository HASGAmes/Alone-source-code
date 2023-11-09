class_name Kick_Skill
extends Skills
var kick_str
var cooldown
var range
var skill_name
var map :MapData
var target:Entity
var tick_cooldown:int
var free_move
var skill_buff:bool
var skill_message
var message_color
func _init(definition:Kick_Skill_Definition):
	kick_str = definition.skill_power
	cooldown = definition.skill_cooldown
	self.free_move = definition.free_move
	range = definition.skill_range
	tick_cooldown = cooldown
	skill_name= definition.skill_name
	self.skill_buff =definition.skill_buff
	self.skill_message = definition.skill_message
	self.message_color = definition.message_color
func activate(user:Entity,action: SkillAction,target_position:Vector2i,mapdata:MapData) -> bool:
	print("kicking?")
	if tick_cooldown == cooldown:
		target = user.map_data.get_actor_at_location(target_position+user.grid_position)
		var knockbackvec = -target_position
		if target == null:
			print("is?")
			MessageLog.send_message("Target Invalid",GameColors.INVALID)
			return false
		MessageLog.send_message(skill_message %[user.get_entity_name(),skill_name,target.get_entity_name()],message_color)
		target.ai_component.attacking_actor = user
		target.knockback(knockbackvec,user.fighter_component.strength_mod+1)
		tick_cooldown = 0
		return true
	else:
		MessageLog.send_message("Skill not off cooldown",GameColors.INVALID)
		return false
