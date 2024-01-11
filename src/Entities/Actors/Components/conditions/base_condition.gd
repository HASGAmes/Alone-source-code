class_name BaseCondition
extends Component

signal condition(condition)

func _init():
	condition.connect(condition_met)
func condition_met()->bool:
	return true
