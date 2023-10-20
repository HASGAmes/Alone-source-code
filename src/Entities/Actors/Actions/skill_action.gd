class_name SkillAction
extends Action

var skill: Skills
var target_position: Vector2i
var User :Entity

func _init(user: Entity, skill: Skills, target_position = null) -> void:
	super._init(user)
	self.skill = skill
	
	User = user
	if not target_position is Vector2i:
		target_position = user.grid_position
	self.target_position = target_position


func get_target_actor() -> Entity:
	return get_map_data().get_actor_at_location(target_position)


func perform() -> bool:
	if skill == null:
		return false
	print(skill)
	return skill.activate(User,self,target_position)

