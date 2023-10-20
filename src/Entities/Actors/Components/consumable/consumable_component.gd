class_name ConsumableComponent
extends Component
var consumable_sfx:AudioStreamWAV
func get_action(consumer: Entity) -> Action:
	return ItemAction.new(consumer, entity)


func activate(action: ItemAction) -> bool:
	return false

func consume(consumer: Entity) -> void:
	
	var inventory: InventoryComponent = consumer.inventory_component
	inventory.items.erase(entity)
	entity.queue_free()
func play_sound(definition:ConsumableComponentDefinition):
	consumable_sfx = definition.consumable_sfx
	if consumable_sfx !=null:
		var item_sfx =Itemsfxs.sfx
		item_sfx.set_stream(consumable_sfx)
		item_sfx.play()
		

func get_targeting_radius() -> int:
	return -1
