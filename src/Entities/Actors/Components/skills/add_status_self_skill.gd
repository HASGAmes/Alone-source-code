class_name AddStatusSelfSkill
extends Skills
var cooldown
var range
var skill_name
var map :MapData
var tick_cooldown:int
var free_move
var skill_buff
var skill_message:String
var status
var message_color
var skill_icon:AtlasTexture
func _init(definition:AddStatusSelfDefinition):
	self.skill_message = definition.skill_message
	cooldown = definition.skill_cooldown
	range = definition.skill_range
	tick_cooldown = cooldown
	self.skill_icon = definition.skill_icon
	self.free_move = definition.free_move
	skill_name= definition.skill_name
	self.status = definition.status
	self.skill_buff =definition.skill_buff
	self.message_color = definition.message_color
func activate(user:Entity,action: SkillAction,target_position:Vector2i,mapdata:MapData) -> bool:
	if tick_cooldown ==cooldown:
		user.add_status([status])
		tick_cooldown = 0
		MessageLog.send_message(skill_message %[user.get_entity_name(),skill_name],message_color)
		return true
	else:
		MessageLog.send_message("Skill not off cooldown",GameColors.INVALID)
		return false
