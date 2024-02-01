class_name  AddStatusEffect
extends BaseEffect
var status
func _init(defition:AddStatusEffectDefinition):
	effect_message = defition.effect_message
	effect_trigger.connect(add_status)
	status = defition.status
	message_color = defition.message_color
func add_status(entity:Entity,target:Entity = null):
	entity.add_status([status])
	print("fadsfdsafaddadsfasdf")
	MessageLog.send_message(effect_message % entity.get_entity_name(),message_color)
	pass
