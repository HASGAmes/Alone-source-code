class_name FoodConsumable
extends ConsumableComponent

var food_amount:int
var food_buff:StatusEffectDefinition
var definition:ConsumableComponentDefinition

func _init(def:FoodConsumableDefinition) ->void:
	definition = def
	food_amount = def.food_amount
	food_buff = def.food_buff
	
func activate(action:ItemAction) -> bool:
	var consumer: Entity = action.entity
	consumer.fighter_component.hunger+=food_amount
	if food_buff:
		print("buff should work")
		consumer.add_status([food_buff])
	MessageLog.send_message("The %s eats the %s" %[consumer.get_entity_name(),get_parent().entity_name],GameColors.HEALTH_RECOVERED)
	consume(consumer)
	play_sound(definition)
	return true
