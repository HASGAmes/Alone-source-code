## definition for conditions with hp at blank settings
class_name HPatBlankDefinition
extends BaseConditionDefinition
## lets you chose if the condition is 
##less than  greater than or equal % of max hp or if it changes at all
@export_enum("Less than","Greater than","Equals","Changes")var condition_parameters:int
@export_range(0,100) var hp_parameter:int = 0## is with the condition parameter to decide what % of max hp is needed
var condition_id = HpatblankCondition## condition id
