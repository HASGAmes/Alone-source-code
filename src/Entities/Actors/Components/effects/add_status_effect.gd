class_name  AddStatusEffect
extends BaseEffect
var status
func _init(defition:AddStatusEffectDefinition):
	effect_message = defition.effect_message
	effect_trigger.connect(add_status)
	status = defition.status
func add_status(entity:Entity):
	entity.add_status([status])
	print("fadsfdsafaddadsfasdf")
	MessageLog.send_message(effect_message,GameColors.IMPOSSIBLE)
	pass
