class_name AddEnemyAttackedStatus
extends BaseEffect
var status
func _init(defition:AddEnemyAttackedStatusDefinition):
	print("sdfsadf")
	effect_message = defition.effect_message
	effect_trigger.connect(add_status)
	message_color = defition.message_color
	status = defition.status
func add_status(entity:Entity,target:Entity):
	print("emited")
	if target !=null:
		print("afssffds")
		target.add_status([status])
		MessageLog.send_message(effect_message%[entity.get_entity_name(),target.get_entity_name()],message_color)
	pass
