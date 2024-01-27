class_name BaseCondition
extends Component

signal condition(condition)
var definition
var effect
func _init(definition:BaseConditionDefinition):
	self.definition = definition
	
	condition.connect(condition_met)
func condition_met()->bool:
	return true
