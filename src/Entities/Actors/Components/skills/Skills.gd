class_name Skills
extends Component

func get_action(user: Entity,skill:Skills) -> Action:
	return SkillAction.new(user, skill)


func activate(user:Entity,action: SkillAction,target_position:Vector2i) -> bool:
	return false
func get_targeting_radius() -> int:
	return -1
