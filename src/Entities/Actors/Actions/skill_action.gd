class_name SkillAction
extends Action

var skill: Skills
var target_position: Vector2i
var User :Entity
var map_data:MapData
func _init(user: Entity, skill: Skills,mapdata:MapData, target_position = null) -> void:
	print(user)
	super._init(user)
	self.skill = skill
	self.map_data = mapdata
	User = user
	if not target_position is Vector2i:
		target_position = user.grid_position
	self.target_position = target_position


func get_target_actor() -> Entity:
	return get_map_data().get_actor_at_location(target_position)


func perform() -> bool:
	if skill == null:
		print(User.get_entity_name())
		return false

	
	return skill.activate(User,self,target_position,map_data)

