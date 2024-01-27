class_name ChangeHpEffect
extends BaseEffect
var hpamount:int
func _init(defition:ChangeHpEffectDefinition):
	effect_message = defition.effect_message
	effect_trigger.connect(change_hp_effect)
	hpamount = defition.hp_changed
func change_hp_effect(entity:Entity):
	entity.fighter_component.heal(hpamount)
	print("fadsfdsafaddadsfasdf")
	MessageLog.send_message(effect_message,GameColors.IMPOSSIBLE)
	pass
