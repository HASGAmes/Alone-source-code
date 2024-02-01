class_name ChangeHpEffect
extends BaseEffect
var hpamount:int
func _init(defition:ChangeHpEffectDefinition):
	effect_message = defition.effect_message
	effect_trigger.connect(change_hp_effect)
	message_color = defition.message_color
	hpamount = defition.hp_changed
func change_hp_effect(entity:Entity):
	entity.fighter_component.heal(hpamount)
	MessageLog.send_message(effect_message%entity.get_entity_name(),message_color)
	pass
