class_name Skills
extends Component

func get_action(user: Entity,skill:Skills,mapdata:MapData) -> Action:
	return SkillAction.new(user, skill,mapdata)


func activate(user:Entity,action: SkillAction,target_position:Vector2i,mapdata:MapData) -> bool:
	return false
func get_targeting_radius() -> int:
	return -1
