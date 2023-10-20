class_name HealingConsumableComponent
extends ConsumableComponent

var amount: int
var defintion
var over_time
var regen
func _init(definition: HealingConsumableComponentDefinition) -> void:
	amount = definition.healing_amount
	defintion=definition
	over_time = defintion.over_time
	regen = definition.regen


func activate(action: ItemAction) -> bool:
	var consumer: Entity = action.entity
	if over_time == false:
		var amount_recovered: int = consumer.fighter_component.heal(consumer.dicebag.roll_dice(1,amount,4))
		if amount_recovered > 0:
			MessageLog.send_message(
				"You consume the %s, and recover %d HP!" % [entity.get_entity_name(), amount_recovered],
				GameColors.HEALTH_RECOVERED
				
			)
			consume(consumer)
			play_sound(defintion)
			return true
		MessageLog.send_message("Your health is already full.", GameColors.IMPOSSIBLE)
		return false
	else:
		var status :RegenStatus
		status = RegenStatus.new(regen)
		consumer.status_tracker.add_child(status)
		MessageLog.send_message(
				"You consume the %s" % entity.get_entity_name(),
				GameColors.HEALTH_RECOVERED
				
			)
		consume(consumer)
		play_sound(defintion)
		return true
