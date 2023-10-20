class_name Kick_Skill
extends Skills
var kick_str
var cooldown
var range
var skill_name
func _init(definition:Kick_Skill_Definition):
	kick_str = definition.skill_power
	cooldown = definition.skill_cooldown
	range = definition.skill_range
	skill_name= definition.skill_name
func activate(user:Entity,action: SkillAction,target_position:Vector2i) -> bool:
	print(entity)
	var mapdata:MapData
	var target = mapdata.get_actor_at_location(target_position)
	
	if target_position == null:
		target_position = entity.grid_position
	var knockbackvec = user.grid_position - target_position
	target.knockback(knockbackvec,kick_str)
	return true
