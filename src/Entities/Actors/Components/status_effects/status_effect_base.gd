## this is the base for all statuses
## You make status by making a definition filling out stats for it then you add a effect
## in the activate_effect function.For more examples check the status effects and status effects definitions to understand it more
class_name StatusBase
extends Component
#template to how to make status effects
func _init(status:StatusEffectDefinition) -> void:
	#setup variables from the definition here
	
	pass
##Any effect for the status effect you trigger here then eventually it ends unless it is special which you can do if needed
func activate_effect(entity:Entity) -> void:
	#Then you can trigger code here for the status effect using the affected entity
	
	
	pass
