class_name RegenStatus
extends StatusBase
var heal:int
var turns:int
var statusname:String
var forever:bool
var stack:bool
func _init(definition: Regen_Definition):
	heal = definition.heal_amount
	stack = definition.can_stack
	turns = definition.turns
	statusname = definition.status_name
	print(definition.is_indefinite)
	forever = definition.is_indefinite
func activate_effect(entity:Entity) -> void:
	entity.fighter_component.heal(heal)
	if forever== false:
		turns = turns -1
	MessageLog.send_message("%s heals for %d health"% [entity.entity_name ,heal],GameColors.HEALTH_RECOVERED)
	if turns <=0:
		queue_free()
	pass
